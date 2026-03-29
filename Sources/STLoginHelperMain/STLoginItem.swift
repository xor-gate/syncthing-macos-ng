import Foundation
import ServiceManagement

class STLoginItem {
    private static let helperBundleIdentifier = "com.github.syncthing.syncthing-macos.Syncthing.LoginHelper"
    
    static func addAppAsLoginItem() {
        // SMLoginItemSetEnabled returns a boolean indicating success.
        let success = SMLoginItemSetEnabled(helperBundleIdentifier as CFString, true)
        
        if success {
            // Track the state locally, as there is no non-deprecated getter in macOS 12
            UserDefaults.standard.set(true, forKey: "LaunchAtLoginEnabled")
        } else {
            print("Failed to enable login item. Ensure the helper app is embedded in Contents/Library/LoginItems.")
        }
    }
    
    static func deleteAppFromLoginItem() {
        let success = SMLoginItemSetEnabled(helperBundleIdentifier as CFString, false)
        
        if success {
            UserDefaults.standard.set(false, forKey: "LaunchAtLoginEnabled")
        } else {
            print("Failed to disable login item.")
        }
    }
    
    static func wasAppAddedAsLoginItem() -> Bool {
        // ⚠️ Note on checking status:
        // Apple deprecated the getter (SMCopyAllJobDictionaries) back in macOS 10.10.
        // To strictly avoid deprecated APIs on macOS 12, the standard community
        // practice is to track the user's preference using UserDefaults.
        return UserDefaults.standard.bool(forKey: "LaunchAtLoginEnabled")
    }
}
