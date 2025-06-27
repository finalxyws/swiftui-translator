import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsModel = SettingsModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: SettingsTab = .api
    
    enum SettingsTab: String, CaseIterable {
        case api = "API Settings"
        case about = "About"
        
        var iconName: String {
            switch self {
            case .api:
                return "gear"
            case .about:
                return "info.circle"
            }
        }
    }
    
    var body: some View {
        HSplitView {
            // Left sidebar navigation
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                VStack(spacing: 4) {
                    ForEach(SettingsTab.allCases, id: \.rawValue) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: tab.iconName)
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(selectedTab == tab ? Color.accentColor : .secondary)
                                
                                Text(tab.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                selectedTab == tab ? Color.accentColor.opacity(0.12) : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .padding(.horizontal, 12)
                    }
                }
                
                Spacer()
            }
            .frame(minWidth: 200, maxWidth: 250)
            .background(.regularMaterial)
            
            // Right content area
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    switch selectedTab {
                    case .api:
                        APISettingsView(settingsModel: settingsModel)
                    case .about:
                        AboutView()
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minWidth: 400)
        }
        .frame(width: 750, height: 550)
        .background(.regularMaterial)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    settingsModel.saveSettings()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!settingsModel.validateSettings())
            }
        }
    }
}

struct APISettingsView: View {
    @ObservedObject var settingsModel: SettingsModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text("API Configuration")
                .font(.title)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
            // Provider Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Translation Provider")
                    .font(.headline)
                    .fontDesign(.rounded)
                
                Picker("Provider", selection: $settingsModel.selectedProvider) {
                    ForEach(SettingsModel.TranslationProvider.allCases, id: \.rawValue) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: settingsModel.selectedProvider) { _, newProvider in
                    settingsModel.customEndpoint = newProvider.defaultEndpoint
                    settingsModel.model = newProvider.defaultModel
                    settingsModel.customPrompt = newProvider.defaultPrompt
                }
            }
            
            // API Key
            VStack(alignment: .leading, spacing: 12) {
                Text("API Key")
                    .font(.headline)
                    .fontDesign(.rounded)
                
                SecureField("Enter your API key", text: $settingsModel.apiKey)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                
                Text("Your API key will be stored securely in the system keychain.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Endpoint
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("API Endpoint")
                        .font(.headline)
                        .fontDesign(.rounded)
                    
                    Spacer()
                    
                    Button("Reset to Default") {
                        settingsModel.customEndpoint = settingsModel.selectedProvider.defaultEndpoint
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                TextField("API Endpoint URL", text: $settingsModel.customEndpoint)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }
            
            // Model
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Model")
                        .font(.headline)
                        .fontDesign(.rounded)
                    
                    Spacer()
                    
                    Button("Reset to Default") {
                        settingsModel.model = settingsModel.selectedProvider.defaultModel
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                TextField("Model name", text: $settingsModel.model)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }
            
            // Custom Prompt
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Translation Prompt")
                        .font(.headline)
                        .fontDesign(.rounded)
                    
                    Spacer()
                    
                    Button("Reset to Default") {
                        settingsModel.customPrompt = settingsModel.selectedProvider.defaultPrompt
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                TextEditor(text: $settingsModel.customPrompt)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 120)
                    .padding(12)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                
                Text("Use {source_language}, {target_language}, and {text} as placeholders.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text("About SwiftUI Translator")
                .font(.title)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    Image(systemName: "translate")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentColor)
                        .symbolEffect(.bounce, value: true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SwiftUI Translator")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        
                        Text("Version \(AppConfig.shared.version)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Developer Information")
                        .font(.headline)
                        .fontDesign(.rounded)
                    
                    HStack {
                        Text("Author:")
                            .fontWeight(.medium)
                        Text(AppConfig.shared.author)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Built with:")
                            .fontWeight(.medium)
                        Text("SwiftUI • Swift 6.0 • macOS 15")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Target Platform:")
                            .fontWeight(.medium)
                        Text("macOS 15.0+")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Features")
                        .font(.headline)
                        .fontDesign(.rounded)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(icon: "globe", text: "Multi-language translation support")
                        FeatureRow(icon: "cpu", text: "AI-powered translation with DeepSeek & OpenAI")
                        FeatureRow(icon: "paintbrush", text: "Modern macOS 15 native design")
                        FeatureRow(icon: "keyboard", text: "Keyboard shortcuts and menu integration")
                        FeatureRow(icon: "doc.on.clipboard", text: "Easy copy and paste functionality")
                        FeatureRow(icon: "gearshape", text: "Customizable API settings")
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("License")
                        .font(.headline)
                        .fontDesign(.rounded)
                    
                    Text("This software is distributed under the MIT License.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 16)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SettingsView()
}
