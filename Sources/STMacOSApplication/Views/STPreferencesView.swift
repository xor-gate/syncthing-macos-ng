import SwiftUI

import STSwiftLibrary

struct STPreferencesView: View {
    @State private var launchAtLogin: Bool = STLoginItem.wasAppAddedAsLoginItem()
    
    //let updaterController: STUpdateController

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General Settings")
                .font(.headline)

            Toggle(isOn: $launchAtLogin) {
                VStack(alignment: .leading) {
                    Text("Launch Syncthing at login")
                    Text("Automatically start the daemon when you log into your Mac.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onChange(of: launchAtLogin) { enabled in
                STLoginItem.setLaunchAtLogin(enabled)
            }

            Divider()

            // --- Software Updates Section ---
            VStack(alignment: .leading, spacing: 8) {
                Text("Software Updates")
                    .font(.headline)
                
                HStack {
                    Text("Check for updates to ensure you have the latest features and security fixes.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Check for Updates...") {
                        // If using Sparkle:
                        //updaterController.checkForUpdates()
                        
                        // If using a custom updater or open-source wrapper:
                        //print("Checking for updates...")
                    }
                }
            }

            Divider()

            // --- Footer: Version & Done Button ---
            HStack {
                Text("Version \(Bundle.main.releaseVersionNumber ?? "1.0.0")")
                    .font(.footnote)
                    //.foregroundColor(.tertiaryLabel)
                
                Spacer()
                
                Button("Done") {
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.large)
            }
        }
        .padding(30)
        .frame(width: 450)
    }
}
