import Foundation
import Combine

protocol TranslationServiceProtocol: Sendable {
    func translate(_ request: TranslationRequest) async throws -> TranslationResponse
}

// MARK: - API Models
struct ChatCompletionRequest: Codable, Sendable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool
    let temperature: Double?
    let maxTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case stream
        case temperature
        case maxTokens = "max_tokens"
    }
    
    init(model: String, messages: [ChatMessage], stream: Bool = false, temperature: Double? = nil, maxTokens: Int? = nil) {
        self.model = model
        self.messages = messages
        self.stream = stream
        self.temperature = temperature
        self.maxTokens = maxTokens
    }
}

struct ChatMessage: Codable, Sendable {
    let role: String
    let content: String
}

struct ChatCompletionResponse: Codable, Sendable {
    let choices: [Choice]
    
    struct Choice: Codable, Sendable {
        let message: ChatMessage
    }
}

// MARK: - Translation Services

final class APITranslationService: TranslationServiceProtocol, @unchecked Sendable {
    private let apiKey: String
    private let endpoint: String
    private let model: String
    private let prompt: String
    
    init(apiKey: String, endpoint: String, model: String, prompt: String) {
        self.apiKey = apiKey
        self.endpoint = endpoint
        self.model = model
        self.prompt = prompt
    }
    
    private func validateAPIKey() throws {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedKey.isEmpty {
            throw TranslationError.noAPIKey
        }
        
        // Basic API key format validation for common patterns
        if endpoint.contains("deepseek.com") && !trimmedKey.hasPrefix("sk-") {
            print("⚠️ Warning: DeepSeek API keys typically start with 'sk-'")
        }
        
        if endpoint.contains("openai.com") && !trimmedKey.hasPrefix("sk-") {
            print("⚠️ Warning: OpenAI API keys typically start with 'sk-'")
        }
        
        if trimmedKey.count < 20 {
            print("⚠️ Warning: API key seems too short (expected 40+ characters)")
        }
    }
    
    func translate(_ request: TranslationRequest) async throws -> TranslationResponse {
        // Validate API key before making the request
        try validateAPIKey()
        
        guard let url = URL(string: endpoint) else {
            throw TranslationError.invalidEndpoint
        }
        
        // Prepare the prompt with placeholders replaced
        let finalPrompt = prompt
            .replacingOccurrences(of: "{source_language}", with: request.sourceLanguage.displayName)
            .replacingOccurrences(of: "{target_language}", with: request.targetLanguage.displayName)
            .replacingOccurrences(of: "{text}", with: request.text)
        
        let chatRequest = ChatCompletionRequest(
            model: model,
            messages: [
                ChatMessage(role: "system", content: "You are a professional translator. Always respond with only the translation, no explanations."),
                ChatMessage(role: "user", content: finalPrompt)
            ],
            stream: false,
            temperature: 0.3,
            maxTokens: 2000
        )
        
        // First attempt with the original endpoint
        do {
            return try await performAPICall(url: url, request: chatRequest, originalRequest: request)
        } catch TranslationError.httpError(404) {
            // If 404 error, try v1 endpoint for DeepSeek compatibility
            if endpoint.contains("api.deepseek.com") && !endpoint.contains("/v1/") {
                let v1Endpoint = endpoint.replacingOccurrences(of: "/chat/completions", with: "/v1/chat/completions")
                print("🔄 Retrying with v1 endpoint: \(v1Endpoint)")
                
                guard let v1URL = URL(string: v1Endpoint) else {
                    throw TranslationError.invalidEndpoint
                }
                
                return try await performAPICall(url: v1URL, request: chatRequest, originalRequest: request)
            } else {
                throw TranslationError.httpError(404)
            }
        }
    }
    
    private func performAPICall(url: URL, request: ChatCompletionRequest, originalRequest: TranslationRequest) async throws -> TranslationResponse {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw TranslationError.encodingError(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            // Debug information for 404 errors
            if httpResponse.statusCode == 404 {
                print("🚨 HTTP 404 Debug Info:")
                print("   Endpoint: \(url.absoluteString)")
                print("   Method: POST")
                print("   Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("   Response Body: \(responseBody)")
                }
            }
            throw TranslationError.httpError(httpResponse.statusCode)
        }
        
        do {
            let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            guard let translatedText = chatResponse.choices.first?.message.content else {
                throw TranslationError.noTranslationResult
            }
            
            return TranslationResponse(
                translatedText: translatedText.trimmingCharacters(in: .whitespacesAndNewlines),
                sourceLanguage: originalRequest.sourceLanguage,
                targetLanguage: originalRequest.targetLanguage,
                originalText: originalRequest.text
            )
        } catch {
            throw TranslationError.decodingError(error)
        }
    }
}

// MARK: - Translation Errors
enum TranslationError: LocalizedError, Sendable {
    case invalidEndpoint
    case encodingError(Error)
    case invalidResponse
    case httpError(Int)
    case noTranslationResult
    case decodingError(Error)
    case noAPIKey
    case noSettings
    
    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "Invalid API endpoint URL. Please check your settings."
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        case .httpError(let code):
            switch code {
            case 401:
                return "Authentication failed. Please check your API key in Settings (⌘,)."
            case 404:
                return "API endpoint not found. This might indicate:\n• Invalid API key\n• Incorrect endpoint URL\n• API service unavailable\n\nPlease verify your settings (⌘,) and try again."
            case 429:
                return "Rate limit exceeded. Please wait a moment and try again."
            case 500...599:
                return "Server error (\(code)). The API service may be temporarily unavailable."
            default:
                return "HTTP error \(code). Please check your internet connection and try again."
            }
        case .noTranslationResult:
            return "No translation result returned from the API."
        case .decodingError(let error):
            return "Failed to decode API response: \(error.localizedDescription)"
        case .noAPIKey:
            return "API key not configured. Please open Settings (⌘,) and enter your API key."
        case .noSettings:
            return "Translation settings not configured. Please open Settings (⌘,) to configure the API."
        }
    }
}

// You can add real translation services here, such as Google Translate API
@MainActor
final class TranslationServiceFactory {
    static func createService(from settings: SettingsModel) -> TranslationServiceProtocol {
        guard !settings.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !settings.customEndpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !settings.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Translation settings not configured. Please configure API settings before using the translator.")
        }
        
        return APITranslationService(
            apiKey: settings.apiKey,
            endpoint: settings.customEndpoint,
            model: settings.model,
            prompt: settings.customPrompt
        )
    }
}
