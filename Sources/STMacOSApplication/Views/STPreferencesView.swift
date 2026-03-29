import SwiftUI

import STSwiftLibrary

struct STPreferencesView: View {
    @State private var launchAtLogin: Bool = STLoginItem.wasAppAddedAsLoginItem()

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
            .onChange(of: launchAtLogin) { newValue in
                if newValue {
                    STLoginItem.addAppAsLoginItem()
                } else {
                    STLoginItem.deleteAppFromLoginItem()
                }
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") {
                    // Close the window
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(30)
        .frame(width: 450)
    }
}
