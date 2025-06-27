import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: Tab? = .api
    @StateObject private var settingsModel = SettingsModel()

    enum Tab: String, CaseIterable, Identifiable {
        case api = "API Settings"
        case about = "About"
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .api: return "gear.circle.fill"
            case .about: return "info.circle.fill"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(Tab.allCases) { tab in
                    NavigationLink(value: tab) {
                        HStack(spacing: 12) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 180, idealWidth: 200, maxWidth: 220)
            .background(.regularMaterial)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header with title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selectedTab?.rawValue ?? "API Settings")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text(getTabDescription(for: selectedTab))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 0) {
                        switch selectedTab {
                        case .api, .none:
                            APISettingsView(settingsModel: settingsModel)
                        case .about:
                            AboutView()
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(.regularMaterial)
        }
        .frame(width: 800, height: 600)
        .onChange(of: settingsModel.selectedProvider) { _, _ in settingsModel.saveSettings() }
        .onChange(of: settingsModel.apiKey) { _, _ in settingsModel.saveSettings() }
        .onChange(of: settingsModel.customEndpoint) { _, _ in settingsModel.saveSettings() }
        .onChange(of: settingsModel.model) { _, _ in settingsModel.saveSettings() }
        .onChange(of: settingsModel.customPrompt) { _, _ in settingsModel.saveSettings() }
    }
    
    private func getTabDescription(for tab: Tab?) -> String {
        switch tab {
        case .api:
            return "Configure your translation API settings and preferences"
        case .about:
            return "Learn more about SwiftUI Translator"
        case .none:
            return "Configure your translation API settings and preferences"
        }
    }
}

struct APISettingsView: View {
    @ObservedObject var settingsModel: SettingsModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            // Provider Selection
            SettingsSection(title: "Translation Provider", description: "Choose your preferred translation service") {
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
            SettingsSection(title: "API Key", description: "Your API key will be stored securely in the system keychain") {
                SecureField("Enter your API key", text: $settingsModel.apiKey)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }
            
            // Endpoint
            SettingsSection(title: "API Endpoint", description: "The endpoint URL for your translation service") {
                HStack {
                    TextField("API Endpoint URL", text: $settingsModel.customEndpoint)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                    
                    Button("Reset") {
                        settingsModel.customEndpoint = settingsModel.selectedProvider.defaultEndpoint
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            // Model
            SettingsSection(title: "Model", description: "The AI model to use for translations") {
                HStack {
                    TextField("Model name", text: $settingsModel.model)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                    
                    Button("Reset") {
                        settingsModel.model = settingsModel.selectedProvider.defaultModel
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            // Custom Prompt
            SettingsSection(title: "Translation Prompt", description: "Customize the prompt used for translation. Use {source_language}, {target_language}, and {text} as placeholders") {
                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $settingsModel.customPrompt)
                        .font(.system(.body, design: .monospaced))
                        .frame(height: 120)
                        .padding(12)
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.secondary.opacity(0.3), lineWidth: 1)
                        )
                    
                    HStack {
                        Spacer()
                        Button("Reset to Default") {
                            settingsModel.customPrompt = settingsModel.selectedProvider.defaultPrompt
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let description: String
    let content: Content
    
    init(title: String, description: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.description = description
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
            content
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            // App Info
            SettingsSection(title: "App Information", description: "SwiftUI Translator - AI-powered translation tool") {
                HStack(spacing: 20) {
                    Image(systemName: "translate")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentColor)
                        .symbolEffect(.bounce, value: true)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SwiftUI Translator")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        
                        Text("Version \(AppConfig.shared.version)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Developer Info
            SettingsSection(title: "Developer Information", description: "Built with modern technologies") {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Author", value: AppConfig.shared.author)
                    InfoRow(label: "Built with", value: "SwiftUI • Swift 6.0 • macOS 15")
                    InfoRow(label: "Target Platform", value: "macOS 15.0+")
                }
            }
            
            // Features
            SettingsSection(title: "Features", description: "Key capabilities of SwiftUI Translator") {
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "globe", text: "Multi-language translation support")
                    FeatureRow(icon: "cpu", text: "AI-powered translation with DeepSeek & OpenAI")
                    FeatureRow(icon: "paintbrush", text: "Modern macOS 15 native design")
                    FeatureRow(icon: "keyboard", text: "Keyboard shortcuts and menu integration")
                    FeatureRow(icon: "doc.on.clipboard", text: "Easy copy and paste functionality")
                    FeatureRow(icon: "gearshape", text: "Customizable API settings")
                }
            }
            
            // License
            SettingsSection(title: "License", description: "This software is distributed under the MIT License") {
                Text("MIT License - Open source software for everyone")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    SettingsView()
}
