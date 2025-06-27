import Foundation

@MainActor
class SettingsModel: ObservableObject {
    @Published var selectedProvider: TranslationProvider = .deepseek
    @Published var apiKey: String = ""
    @Published var customEndpoint: String = ""
    @Published var model: String = ""
    @Published var customPrompt: String = ""
    
    // Default configurations
    private let defaults = UserDefaults.standard
    
    enum TranslationProvider: String, CaseIterable, Sendable {
        case deepseek = "deepseek"
        case openai = "openai"
        
        var displayName: String {
            switch self {
            case .deepseek:
                return "DeepSeek"
            case .openai:
                return "OpenAI"
            }
        }
        
        var defaultEndpoint: String {
            switch self {
            case .deepseek:
                return "https://api.deepseek.com/chat/completions"
            case .openai:
                return "https://api.openai.com/v1/chat/completions"
            }
        }
        
        var defaultModel: String {
            switch self {
            case .deepseek:
                return "deepseek-chat"
            case .openai:
                return "gpt-3.5-turbo"
            }
        }
        
        var defaultPrompt: String {
            return """
Translate the following text from {source_language} to {target_language}. 
Provide only the translation result without any explanations, prefixes, or additional text.

Text: {text}
"""
        }
    }
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        if let providerRaw = defaults.string(forKey: "selectedProvider"),
           let provider = TranslationProvider(rawValue: providerRaw) {
            selectedProvider = provider
        }
        
        apiKey = defaults.string(forKey: "apiKey") ?? ""
        customEndpoint = defaults.string(forKey: "customEndpoint") ?? selectedProvider.defaultEndpoint
        model = defaults.string(forKey: "model") ?? selectedProvider.defaultModel
        customPrompt = defaults.string(forKey: "customPrompt") ?? selectedProvider.defaultPrompt
    }
    
    func saveSettings() {
        defaults.set(selectedProvider.rawValue, forKey: "selectedProvider")
        defaults.set(apiKey, forKey: "apiKey")
        defaults.set(customEndpoint, forKey: "customEndpoint")
        defaults.set(model, forKey: "model")
        defaults.set(customPrompt, forKey: "customPrompt")
    }
    
    func resetToDefaults() {
        customEndpoint = selectedProvider.defaultEndpoint
        model = selectedProvider.defaultModel
        customPrompt = selectedProvider.defaultPrompt
        saveSettings()
    }
    
    func validateSettings() -> Bool {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        guard !customEndpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        guard !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
}
