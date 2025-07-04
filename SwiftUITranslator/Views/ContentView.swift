import SwiftUI

struct ContentView: View {
    @StateObject private var translatorVM = TranslatorViewModel()
    @EnvironmentObject private var settingsModel: SettingsModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header section with title
            VStack(spacing: 32) {
                Text("SwiftUI Translator")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .padding(.top, 40)
                
                // Language selectors with modern card design
                HStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Picker("Source Language", selection: $translatorVM.sourceLanguage) {
                            ForEach(Language.allCases, id: \.self) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(minWidth: 180, idealWidth: 220, maxWidth: 280)
                        .controlSize(.large)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: {
                        withAnimation(.smooth(duration: 0.5)) {
                            translatorVM.swapLanguages()
                        }
                    }) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.title2)
                            .fontWeight(.medium)
                            .symbolEffect(.rotate, value: translatorVM.sourceLanguage)
                            .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.borderless)
                    
                    VStack(spacing: 12) {
                        Picker("Target Language", selection: $translatorVM.targetLanguage) {
                            ForEach(Language.allCases, id: \.self) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(minWidth: 180, idealWidth: 220, maxWidth: 280)
                        .controlSize(.large)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            
            // Main content area
            VStack(spacing: 32) {
                // Input and output areas with modern design
                HStack(spacing: 32) {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Input Text")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Spacer()
                            HStack(spacing: 2) {
                                Text("\(translatorVM.inputText.count)")
                                    .font(.callout)
                                    .foregroundStyle(translatorVM.inputText.count > TranslatorViewModel.warningThreshold ? .orange : translatorVM.inputText.count >= TranslatorViewModel.maxInputLength ? .red : .secondary)
                                Text("/")
                                    .font(.callout)
                                    .foregroundStyle(translatorVM.inputText.count > TranslatorViewModel.warningThreshold ? .orange : translatorVM.inputText.count >= TranslatorViewModel.maxInputLength ? .red : .secondary)
                                    .padding(.horizontal, 2)
                                Text("\(TranslatorViewModel.maxInputLength)")
                                    .font(.callout)
                                    .foregroundStyle(translatorVM.inputText.count > TranslatorViewModel.warningThreshold ? .orange : translatorVM.inputText.count >= TranslatorViewModel.maxInputLength ? .red : .secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                (translatorVM.inputText.count > TranslatorViewModel.warningThreshold ?
                                    Color.orange.opacity(0.08) :
                                    translatorVM.inputText.count >= TranslatorViewModel.maxInputLength ?
                                        Color.red.opacity(0.08) :
                                        Color.secondary.opacity(0.07)),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        translatorVM.inputText.count > TranslatorViewModel.warningThreshold ?
                                            Color.orange.opacity(0.3) :
                                            translatorVM.inputText.count >= TranslatorViewModel.maxInputLength ?
                                                Color.red.opacity(0.3) :
                                                Color.clear,
                                        lineWidth: 1
                                    )
                            )
                        }
                        
                        TextEditor(text: Binding(
                            get: { translatorVM.inputText },
                            set: { newValue in
                                if newValue.count <= TranslatorViewModel.maxInputLength {
                                    translatorVM.inputText = newValue
                                }
                            }
                        ))
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .lineSpacing(8)
                            .padding(20)
                            .scrollContentBackground(.hidden)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .frame(minHeight: 240, maxHeight: 320)
                            .contentTransition(.numericText())
                    }
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Translation Result")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.bouncy) {
                                    translatorVM.copyToClipboard()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: translatorVM.isCopied ? "checkmark" : "doc.on.doc")
                                        .font(.system(size: 14, weight: .medium))
                                        .symbolEffect(.bounce, value: translatorVM.translatedText)
                                        .symbolEffect(.bounce, value: translatorVM.isCopied)
                                    
                                    Text(translatorVM.isCopied ? "Copied!" : "Copy")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(translatorVM.isCopied ? .green : Color.accentColor)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .font(.body)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.secondary.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .disabled(translatorVM.translatedText.isEmpty)
                            .buttonStyle(.borderless)
                            .scaleEffect(translatorVM.translatedText.isEmpty ? 0.8 : 1.0)
                            .opacity(translatorVM.translatedText.isEmpty ? 0.5 : 1.0)
                            .animation(.smooth(duration: 0.2), value: translatorVM.translatedText.isEmpty)
                            .animation(.smooth(duration: 0.3), value: translatorVM.isCopied)
                        }
                        
                        ScrollView {
                            Text(translatorVM.translatedText.isEmpty ? "Translation will appear here..." : translatorVM.translatedText)
                                .font(.system(size: 16, weight: .regular, design: .default))
                                .lineSpacing(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                .textSelection(.enabled)
                                .foregroundStyle(translatorVM.translatedText.isEmpty ? .secondary : .primary)
                                .contentTransition(.opacity)
                        }
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .frame(minHeight: 240, maxHeight: 320)
                    }
                }
                
                // Action buttons with enhanced styling
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.snappy) {
                            translatorVM.translate()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: translatorVM.isTranslating ? "arrow.clockwise" : "arrow.right")
                                .font(.system(size: 16, weight: .medium))
                                .symbolEffect(.bounce, value: translatorVM.isTranslating)
                                .rotationEffect(.degrees(translatorVM.isTranslating ? 360 : 0))
                                .animation(
                                    translatorVM.isTranslating ? 
                                        .linear(duration: 1).repeatForever(autoreverses: false) : 
                                        .smooth(duration: 0.3),
                                    value: translatorVM.isTranslating
                                )
                            
                            Text(translatorVM.isTranslating ? "Translating..." : "Translate")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            translatorVM.isTranslating ? 
                                LinearGradient(colors: [.blue.opacity(0.8), .blue], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .scaleEffect(translatorVM.inputText.isEmpty || translatorVM.isTranslating ? 0.95 : 1.0)
                        .opacity(translatorVM.inputText.isEmpty || translatorVM.isTranslating ? 0.7 : 1.0)
                    }
                    .buttonStyle(.borderless)
                    .disabled(translatorVM.inputText.isEmpty || translatorVM.isTranslating)
                    .animation(.smooth(duration: 0.2), value: translatorVM.inputText.isEmpty)
                    .animation(.smooth(duration: 0.3), value: translatorVM.isTranslating)
                    
                    Button(action: {
                        withAnimation(.smooth) {
                            translatorVM.clearText()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .medium))
                                .symbolEffect(.bounce, value: translatorVM.inputText.isEmpty && translatorVM.translatedText.isEmpty)
                            
                            Text("Clear")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .scaleEffect(translatorVM.inputText.isEmpty && translatorVM.translatedText.isEmpty ? 0.95 : 1.0)
                        .opacity(translatorVM.inputText.isEmpty && translatorVM.translatedText.isEmpty ? 0.5 : 1.0)
                    }
                    .buttonStyle(.borderless)
                    .disabled(translatorVM.inputText.isEmpty && translatorVM.translatedText.isEmpty)
                    .animation(.smooth(duration: 0.2), value: translatorVM.inputText.isEmpty && translatorVM.translatedText.isEmpty)
                    
                    if translatorVM.isTranslating {
                        ProgressView()
                            .controlSize(.regular)
                            .scaleEffect(0.9)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                
                // Error message display with enhanced styling
                if let errorMessage = translatorVM.errorMessage {
                    HStack {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .fontDesign(.rounded)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.red.opacity(0.3), lineWidth: 1)
                            )
                            .transition(.scale.combined(with: .opacity))
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            Spacer(minLength: 32)
        }
        .frame(minWidth: AppConfig.shared.minWindowWidth, minHeight: AppConfig.shared.minWindowHeight)
        .background(.regularMaterial)
        .animation(.smooth(duration: 0.3), value: translatorVM.isTranslating)
        .animation(.smooth(duration: 0.3), value: translatorVM.errorMessage)
        .onAppear {
            translatorVM.configure(with: settingsModel)
        }
    }
}

#Preview {
    ContentView()
}
