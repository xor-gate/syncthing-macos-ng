import Foundation

public struct STConfiguration: Codable {
    public var apiKey: String = ""
    public var url: String = "http://127.0.0.1:8384"
    public var autoStart: Bool = false
}

public struct STConfigurationStorage
{
    public static let suiteName = "com.github.syncthing.syncthing-macos"
    public static let shared: Foundation.UserDefaults = {
        let name = "group.org.syncthing.macos"
        return Foundation.UserDefaults(suiteName: name) ?? .standard
    }()
    
    @STConfigurationUserDefaults(key: "cfg", defaultValue: STConfiguration(), container: shared)
    public static var UserDefaults: STConfiguration
}
