import Foundation

struct AppConfig {
    static let shared = AppConfig()
    
    // App information
    let appName = "SwiftUI Translator"
    let version = "1.0.0"
    let author = "Sheldon"
    
    // Window settings for macOS 15
    let minWindowWidth: CGFloat = 900
    let minWindowHeight: CGFloat = 650
    let defaultWindowWidth: CGFloat = 1100
    let defaultWindowHeight: CGFloat = 750
    
    // Translation settings
    let autoTranslateDelay: Double = 1.0 // seconds
    let maxTextLength: Int = 5000
    
    // Supported translation services
    enum TranslationProvider: String, CaseIterable {
        case mock = "mock"
        case google = "google"
        case baidu = "baidu"
        
        var displayName: String {
            switch self {
            case .mock:
                return "Mock Translation"
            case .google:
                return "Google Translate"
            case .baidu:
                return "Baidu Translate"
            }
        }
    }
    
    // Default language settings
    let defaultSourceLanguage = Language.english
    let defaultTargetLanguage = Language.chinese
    
    // UserDefaults keys
    struct UserDefaultsKeys {
        static let sourceLanguage = "source_language"
        static let targetLanguage = "target_language"
        static let translationProvider = "translation_provider"
        static let autoTranslateEnabled = "auto_translate_enabled"
    }
    
    private init() {}
}
