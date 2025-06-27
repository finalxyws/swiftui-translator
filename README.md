# SwiftUI Translator

A professional SwiftUI-based macOS translation application optimized for **macOS 15** with modern UI and AI-powered translation capabilities.

## 🎯 macOS 15 Optimizations

This app is specifically designed for **macOS 15** and leverages the latest features:

- **🪟 Window Background Drag Behavior**: Enabled modern window dragging
- **✨ SF Symbols Effects**: Animated symbols with bounce and rotate effects
- **🎨 Material Backgrounds**: Native `.regularMaterial` backgrounds throughout
- **⚡ Swift 6 Concurrency**: Full adoption of modern async/await patterns
- **🎭 Advanced Animations**: Smooth, bouncy, and snappy animations
- **⌨️ Keyboard Shortcuts**: Native macOS keyboard integration

## Features

- 🌍 **Multi-language translation support** (10+ languages)
- 🔄 **Smart language swap** with animated transitions
- 🤖 **AI-powered translation** via DeepSeek and OpenAI APIs
- 📋 **One-click copy** to clipboard with visual feedback
- ⚙️ **Comprehensive settings** with API configuration
- 🎨 **Modern macOS 15 design** with native materials
- ⌨️ **Full keyboard shortcuts** (⌘T, ⌘,, ⌘S, etc.)
- 🖥️ **Native macOS integration** with menu commands

## Supported Languages

- Chinese (zh)
- English (en)
- Japanese (ja)
- Korean (ko)
- French (fr)
- German (de)
- Spanish (es)
- Russian (ru)
- Arabic (ar)
- Portuguese (pt)

## Project Structure

```
SwiftUITranslator/
├── SwiftUITranslatorApp.swift    # Application entry point
├── Views/
│   └── ContentView.swift         # Main interface view
├── Models/
│   ├── Language.swift            # Language model
│   └── TranslatorViewModel.swift # View model
└── Services/
    └── TranslationService.swift  # Translation service
```

### Installation Methods

#### Using Xcode (macOS 15)
1. Open `SwiftUITranslator.xcodeproj` in Xcode
2. Ensure deployment target is set to macOS 15.0
3. Build and run (⌘R)

#### Using Swift Package Manager
```bash
swift build
swift run
```

## 🔧 Configuration

1. **Launch the app** and press `⌘,` to open Settings
2. **Choose API Provider**: DeepSeek (recommended) or OpenAI
3. **Enter your API Key**: Get from [DeepSeek](https://platform.deepseek.com/) or [OpenAI](https://platform.openai.com/)
4. **Customize settings**: Endpoint, model, and translation prompt
5. **Save settings** and start translating!

## 📋 Requirements

- **macOS 15.0+** (Sequoia)
- **Xcode 16.0+** (for development)
- **Swift 6.0+**
- **API Key** from DeepSeek or OpenAI

## Development Status

✅ **Completed Features**:
- Native macOS 15 UI with modern materials
- Real-time AI translation (DeepSeek/OpenAI)
- Complete settings system with API configuration  
- Keyboard shortcuts and menu integration
- Symbol effects and smooth animations
- Professional error handling and user feedback

🚀 **Future Enhancements**:
- [ ] Translation history and favorites
- [ ] Batch file translation
- [ ] Voice input and speech output  
- [ ] Additional AI providers (Claude, Gemini)
- [ ] Custom translation memory
- [ ] Add theme switching functionality
- [ ] Support offline translation

## Tech Stack

- SwiftUI
- Combine
- Foundation
- macOS 13+

## License

MIT License