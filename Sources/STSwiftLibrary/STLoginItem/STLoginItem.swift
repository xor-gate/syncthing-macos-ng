import Foundation
import ServiceManagement

public class STLoginItem {
    private static let helperBundleIdentifier = "com.github.syncthing.syncthing-macos.Syncthing.LoginHelper"
    public static let userDefaultsKey = "LaunchAtLoginEnabled"

    public static func setLaunchAtLogin(_ enabled: Bool) {
        let success = SMLoginItemSetEnabled(helperBundleIdentifier as CFString, enabled)
        if success {
            UserDefaults.standard.set(enabled, forKey: userDefaultsKey)
        } else {
            print("STLoginItem: Failed to change login item state. Check Console for 'smd' errors.")
        }
    }
    
    public static func addAppAsLoginItem() {
        // SMLoginItemSetEnabled returns a boolean indicating success.
        let success = SMLoginItemSetEnabled(helperBundleIdentifier as CFString, true)
        
        if success {
            // Track the state locally, as there is no non-deprecated getter in macOS 12
            UserDefaults.standard.set(true, forKey: userDefaultsKey)
        } else {
            print("Failed to enable login item. Ensure the helper app is embedded in Contents/Library/LoginItems.")
        }
    }
    
    public static func deleteAppFromLoginItem() {
        let success = SMLoginItemSetEnabled(helperBundleIdentifier as CFString, false)
        
        if success {
            UserDefaults.standard.set(false, forKey: userDefaultsKey)
        } else {
            print("Failed to disable login item.")
        }
    }
    
    public static func wasAppAddedAsLoginItem() -> Bool {
        // ⚠️ Note on checking status:
        // Apple deprecated the getter (SMCopyAllJobDictionaries) back in macOS 10.10.
        // To strictly avoid deprecated APIs on macOS 12, the standard community
        // practice is to track the user's preference using UserDefaults.
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
}
