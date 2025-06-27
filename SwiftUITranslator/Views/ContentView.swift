import SwiftUI

struct ContentView: View {
    @StateObject private var translatorVM = TranslatorViewModel()
    @EnvironmentObject private var settingsModel: SettingsModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header section with title
            VStack(spacing: 20) {
                Text("SwiftUI Translator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                    .padding(.top, 24)
                
                // Language selectors with modern card design
                HStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Picker("Source Language", selection: $translatorVM.sourceLanguage) {
                            ForEach(Language.allCases, id: \.self) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(minWidth: 160, idealWidth: 200, maxWidth: 250)
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
                    
                    VStack(spacing: 8) {
                        Picker("Target Language", selection: $translatorVM.targetLanguage) {
                            ForEach(Language.allCases, id: \.self) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(minWidth: 160, idealWidth: 200, maxWidth: 250)
                        .controlSize(.large)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
            
            // Main content area
            VStack(spacing: 20) {
                // Input and output areas with modern design
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Input Text")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(translatorVM.inputText.count)")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.quaternary, in: Capsule())
                        }
                        
                        TextEditor(text: $translatorVM.inputText)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .lineSpacing(6)
                            .padding(16)
                            .scrollContentBackground(.hidden)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.quaternary, lineWidth: 1)
                            )
                            .frame(height: 200)
                            .contentTransition(.numericText())
                    }
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Translation Result")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.bouncy) {
                                    translatorVM.copyToClipboard()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: translatorVM.isCopied ? "checkmark" : "doc.on.doc")
                                        .font(.system(size: 14, weight: .medium))
                                        .symbolEffect(.bounce, value: translatorVM.translatedText)
                                        .symbolEffect(.bounce, value: translatorVM.isCopied)
                                    
                                    Text(translatorVM.isCopied ? "Copied!" : "Copy")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(translatorVM.isCopied ? .green : Color.accentColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.quaternary, lineWidth: 1)
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
                                .lineSpacing(6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .textSelection(.enabled)
                                .foregroundStyle(translatorVM.translatedText.isEmpty ? .secondary : .primary)
                                .contentTransition(.opacity)
                        }
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.quaternary, lineWidth: 1)
                        )
                        .frame(height: 200)
                    }
                }
                
                // Action buttons with enhanced styling
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.snappy) {
                            translatorVM.translate()
                        }
                    }) {
                        HStack(spacing: 8) {
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
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
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .medium))
                                .symbolEffect(.bounce, value: translatorVM.inputText.isEmpty && translatorVM.translatedText.isEmpty)
                            
                            Text("Clear")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.quaternary, lineWidth: 1)
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
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
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
            .padding(.horizontal, 32)
            .padding(.bottom, 8)
            
            Spacer(minLength: 24)
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
