import Foundation

public struct STConfigurationXMLGUIConfig {
    public var enabled: Bool = false
    public var tls: Bool = false
    public var address: String = ""
    public var apiKey: String = ""
    public var theme: String = "default"
    
    // Helper to get a full URL from the address
    public var apiURL: URL? {
        let prefix = tls ? "https://" : "http://"
        return URL(string: "\(prefix)\(address)")
    }
}

public class STConfigurationXMLReader: NSObject, XMLParserDelegate {
    public var gui = STConfigurationXMLGUIConfig()
    private var currentElement = ""
    private var tempCharacters = ""
    private var isInGuiTag = false

    let configURL: URL
    public let defaultPath = NSString(string: "~/Library/Application Support/Syncthing/config.xml").expandingTildeInPath
    
    public init(path: String? = nil) {
        let resolvedPath = path ?? NSString(string: defaultPath).expandingTildeInPath
        self.configURL = URL(fileURLWithPath: resolvedPath)
        super.init()
    }
    
    public func parse() -> Bool {
        guard let parser = XMLParser(contentsOf: configURL) else { return false }
        parser.delegate = self
                
        let result = parser.parse()
        return result
    }
    
    // MARK: - XMLParserDelegate
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            currentElement = elementName
            tempCharacters = ""
            
            if elementName == "gui" {
                isInGuiTag = true
                // Parse attributes: <gui enabled="true" tls="false">
                if let enabledStr = attributeDict["enabled"] {
                    gui.enabled = (enabledStr == "true")
                }
                if let tlsStr = attributeDict["tls"] {
                    gui.tls = (tlsStr == "true")
                }
            }
        }
        
        public func parser(_ parser: XMLParser, foundCharacters string: String) {
            if isInGuiTag {
                tempCharacters += string
            }
        }
        
        public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            guard isInGuiTag else { return }
            
            let value = tempCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            
            switch elementName {
            case "address":
                gui.address = value
            case "apikey":
                gui.apiKey = value
            case "theme":
                gui.theme = value
            case "gui":
                isInGuiTag = false // Exit the GUI block
            default:
                break
            }
        }
}
