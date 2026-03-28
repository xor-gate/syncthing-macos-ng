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
        return Foundation.UserDefaults(suiteName: suiteName) ?? .standard
    }()

    //@STConfigurationUserDefaults(key: "cfg", defaultValue: STConfiguration(), container: shared)
    //public var Config: STConfiguration
    public var XML: STConfigurationXMLReader
    
    public init() {
        //self.Config = STConfiguration()
        self.XML = STConfigurationXMLReader()
    }
}
