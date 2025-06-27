import SwiftUI

@main
struct SwiftUITranslatorApp: App {
    @StateObject private var settingsModel = SettingsModel()
    
    var body: some Scene {
        Group {
            mainWindow
            settingsWindow
        }
    }
    
    private var mainWindow: some Scene {
        let windowGroup = WindowGroup {
            ContentView()
                .environmentObject(settingsModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(
            width: AppConfig.shared.defaultWindowWidth,
            height: AppConfig.shared.defaultWindowHeight
        )
        .commands {
            // Add menu commands with enhanced functionality
            CommandGroup(replacing: .appInfo) {
                Button("About \(AppConfig.shared.appName)") {
                    // TODO: Show about dialog
                }
                .keyboardShortcut("a", modifiers: .command)
            }
            
            CommandGroup(after: .textEditing) {
                Button("Translate") {
                    // TODO: Trigger translation via menu
                }
                .keyboardShortcut("t", modifiers: .command)
                
                Button("Swap Languages") {
                    // TODO: Swap languages via menu
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Clear Text") {
                    // TODO: Clear text via menu
                }
                .keyboardShortcut("k", modifiers: .command)
            }
        }
        
        return windowGroup.windowBackgroundDragBehavior(.enabled)
    }
    
    private var settingsWindow: some Scene {
        Settings {
            SettingsView()
                .environmentObject(settingsModel)
        }
    }
}
