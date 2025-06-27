import Foundation
import Combine
#if os(macOS)
import AppKit
#endif

@MainActor
class TranslatorViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var translatedText: String = ""
    @Published var sourceLanguage: Language = .english
    @Published var targetLanguage: Language = .chinese
    @Published var isTranslating: Bool = false
    @Published var errorMessage: String?
    @Published var isCopied: Bool = false
    
    private var settingsModel: SettingsModel?
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsModel: SettingsModel? = nil) {
        self.settingsModel = settingsModel
        
        // Auto-translation feature (optional)
        setupAutoTranslation()
    }
    
    func configure(with settingsModel: SettingsModel) {
        self.settingsModel = settingsModel
    }
    
    private func setupAutoTranslation() {
        // Auto-translate when input text changes, with 1 second delay
        $inputText
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                if !text.isEmpty && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Task {
                        await self?.translate()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func translate() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Get the translation service based on current settings
        guard let settingsModel = settingsModel else {
            errorMessage = "Settings not configured"
            return
        }
        
        isTranslating = true
        errorMessage = nil
        
        do {
            let request = TranslationRequest(
                text: inputText,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            )
            
            // Create service from current settings (on MainActor)
            let service = TranslationServiceFactory.createService(from: settingsModel)
            let response = try await service.translate(request)
            translatedText = response.translatedText
        } catch {
            errorMessage = "Translation failed: \(error.localizedDescription)"
            translatedText = ""
        }
        
        isTranslating = false
    }
    
    func translate() {
        Task {
            await translate()
        }
    }
    
    func swapLanguages() {
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        // Swap input and output text
        let tempText = inputText
        inputText = translatedText
        translatedText = tempText
    }
    
    func clearText() {
        inputText = ""
        translatedText = ""
        errorMessage = nil
    }
    
    func copyToClipboard() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(translatedText, forType: .string)
        
        // Show copy success feedback
        isCopied = true
        
        // Reset the copied state after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            isCopied = false
        }
        #endif
    }
}
