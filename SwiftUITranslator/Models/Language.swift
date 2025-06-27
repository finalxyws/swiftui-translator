import Foundation

enum Language: String, CaseIterable, Sendable {
    case chinese = "zh"
    case english = "en"
    case japanese = "ja"
    case korean = "ko"
    case french = "fr"
    case german = "de"
    case spanish = "es"
    case russian = "ru"
    case arabic = "ar"
    case portuguese = "pt"
    
    var displayName: String {
        switch self {
        case .chinese:
            return "Chinese"
        case .english:
            return "English"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .french:
            return "Français"
        case .german:
            return "Deutsch"
        case .spanish:
            return "Español"
        case .russian:
            return "Русский"
        case .arabic:
            return "العربية"
        case .portuguese:
            return "Português"
        }
    }
    
    var code: String {
        return self.rawValue
    }
}

struct TranslationRequest: Sendable {
    let text: String
    let sourceLanguage: Language
    let targetLanguage: Language
}

struct TranslationResponse: Sendable {
    let translatedText: String
    let sourceLanguage: Language
    let targetLanguage: Language
    let originalText: String
}
