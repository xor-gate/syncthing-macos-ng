import Foundation

struct STConfiguration: Codable {
    var apiKey: String = ""
    var url: String = "http://127.0.0.1:8384"
    var autoStart: Bool = false
}

struct STConfigurationStorage
{
    static let suiteName = "com.github.syncthing.syncthing-macos";
    static let shared: Foundation.UserDefaults = {
        let name = "group.org.syncthing.macos"
        return Foundation.UserDefaults(suiteName: name) ?? .standard
    }()
    
    @STConfigurationUserDefaults(key: "cfg", defaultValue: STConfiguration(), container: shared)
    static var UserDefaults: STConfiguration
}
