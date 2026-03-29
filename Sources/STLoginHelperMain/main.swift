import AppKit

class STLoginHelperDelegate: NSObject, NSApplicationDelegate {
    
    // ⚠️ Replace with your Main Application's Bundle Identifier
    let mainAppIdentifier = "com.github.syncthing.syncthing-macos.Syncthing"
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains { $0.bundleIdentifier == mainAppIdentifier }
        
        if !isRunning {
            // The helper app lives at:
            // MainApp.app/Contents/Library/LoginItems/LoginHelper.app
            // We need to navigate up 4 directories to find the MainApp.app
            
            var path = Bundle.main.bundleURL
            for _ in 0..<4 {
                path = path.deletingLastPathComponent()
            }
            
            // Launch the main app
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.promptsUserIfNeeded = false
            
            NSWorkspace.shared.openApplication(at: path, configuration: configuration) { _, error in
                if let error = error {
                    print("Failed to launch main app: \(error.localizedDescription)")
                }
                // Terminate the helper once the job is done
                NSApp.terminate(nil)
            }
        } else {
            // Main app is already running, no need to do anything
            NSApp.terminate(nil)
        }
    }
}

// Bootstrap the application lifecycle
let app = NSApplication.shared
let delegate = STLoginHelperDelegate()

app.delegate = delegate
app.run()
