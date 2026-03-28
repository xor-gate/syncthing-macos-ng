import Testing
@testable import STSwiftLibrary

struct STAPIClientTests {
    @Test func getSystemStatus() async throws {
        let client = STAPIClient(url: "http://127.0.0.1:8384", apiKey: "xo9iAMwkdNRGwMrbnzENeCvXjnj6QGjX")
        do {
            let ss = try await client.getSystemStatus()
            print(ss.myID)
        } catch {
            // Ignore
        }
    }
    
    @Test func getEvents() async throws {
        let client = STAPIClient(url: "http://127.0.0.1:8384", apiKey: "xo9iAMwkdNRGwMrbnzENeCvXjnj6QGjX")
        do {
                print("Starting event monitor...")
                for try await event in client.eventStream() {
                    switch event.type {
                        case .itemFinished:
                            if let info = event.itemInfo {
                                let status = info.error == nil ? "✅" : "❌"
                                print("\(status) \(info.action): \(info.item) in \(info.folder)")
                            }
                            
                        case .folderSummary:
                            if let summary = event.folderSummary {
                                print("📁 Folder \(summary.folder) is now \(summary.summary.state)")
                            }
                            
                        case .deviceConnected:
                            if let device = event.deviceInfo {
                                print("📱 Device \(device.deviceID) connected via \(device.address ?? "unknown")")
                            }
                            
                        default:
                            print("Unhandled event \(event.type)")
                            break
                        }
                }
            } catch {
                print("Stream stopped: \(error)")
            }
    }

}
