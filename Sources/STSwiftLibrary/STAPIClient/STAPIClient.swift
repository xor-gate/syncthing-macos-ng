import Foundation

// MARK: - Core Client
public class STAPIClient {
    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        // Syncthing format: "2023-10-05T14:48:00.123456789+02:00"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Attempt the high-precision format first
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Fallback for versions of Syncthing that might omit fractional seconds
            let fallbackFormatter = ISO8601DateFormatter()
            if let date = fallbackFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }()

    public init(url: URL, apiKey: String) {
        self.baseURL = url
        self.apiKey = apiKey
        self.session = URLSession.shared
    }

    public func getBaseURL() -> URL {
        return self.baseURL
    }
    
    private func performRequest<T: Codable>(endpoint: String, method: String = "GET") async throws -> T {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw SyncthingError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 500
            throw SyncthingError.requestFailed(code)
        }

        // Handle empty responses for 200 OK POSTs
        if data.isEmpty, T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }

        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Native Methods
    
    public func getSystemStatus() async throws -> SystemStatus {
        return try await performRequest(endpoint: "/rest/system/status")
    }

    /// Gets the list of all configured folders
    public func getFolders() async throws -> [FolderConfiguration] {
        let config: SyncthingFullConfig = try await performRequest(endpoint: "/rest/config")
        return config.folders
    }

    /// Gets the runtime status (sync progress, state) for a specific folder
    public func getFolderStatus(id: String) async throws -> FolderStatus {
        return try await performRequest(endpoint: "/rest/db/status?folder=\(id)")
    }
    
    public func eventStream(since: Int = 0) -> AsyncThrowingStream<SyncthingEvent, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                var lastID = since
                while !Task.isCancelled {
                    do {
                        let endpoint = "/rest/events?since=\(lastID)"
                        let events: [SyncthingEvent] = try await self.performRequest(endpoint: endpoint)
                        for event in events {
                            continuation.yield(event)
                            lastID = max(lastID, event.id)
                        }
                    } catch {
                        continuation.finish(throwing: error)
                        break
                    }
                }
            }
            continuation.onTermination = { @Sendable _ in task.cancel() }
        }
    }
}

// MARK: - Models & Enums

public enum SyncthingError: Error {
    case invalidURL
    case requestFailed(Int)
}

public struct EmptyResponse: Codable {}

public struct SystemStatus: Codable {
    public let myID: String
    public let uptime: Int
    public let cpuPercent: Double
}

public struct SyncthingFullConfig: Codable {
    public let folders: [FolderConfiguration]
}

public struct SyncthingEvent: Codable, Identifiable {
    public let id: Int
    public let globalID: Int
    public let time: Date
    public let type: EventType
    public let data: [String: AnyCodable]? // Use a Type-Safe wrapper or [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case id, globalID, time, type, data
    }
    
    public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Basic fields
            self.id = try container.decode(Int.self, forKey: .id)
            self.globalID = try container.decode(Int.self, forKey: .globalID)
            self.time = try container.decode(Date.self, forKey: .time)
            self.type = try container.decode(EventType.self, forKey: .type)
            
            // The Fix: Safely decode data if present, otherwise set to nil
            self.data = try container.decodeIfPresent([String: AnyCodable].self, forKey: .data)
        }
    
    // Helper to re-decode the generic dictionary into a specific struct
        private func decodeData<T: Codable>(_ type: T.Type) -> T? {
            guard let data = data else { return nil }
            do {
                let json = try JSONSerialization.data(withJSONObject: data.mapValues { $0.value })
                return try JSONDecoder().decode(T.self, from: json)
            } catch {
                print("❌ Failed to cast event data to \(T.self): \(error)")
                return nil
            }
        }

        // --- Type-Safe Properties ---

        var itemInfo: ItemEventData? {
            guard type == .itemStarted || type == .itemFinished else { return nil }
            return decodeData(ItemEventData.self)
        }

        var folderSummary: FolderSummaryData? {
            guard type == .folderSummary else { return nil }
            return decodeData(FolderSummaryData.self)
        }

        var deviceInfo: DeviceEventData? {
            guard type == .deviceConnected || type == .deviceDisconnected else { return nil }
            return decodeData(DeviceEventData.self)
        }
}

public enum EventType: String, Codable, CaseIterable {
    // --- System & Config ---
    case starting               = "Starting"
    case startupComplete        = "StartupComplete"
    case configSaved            = "ConfigSaved"
    case serviceStarted         = "ServiceStarted"
    case loginAttempt           = "LoginAttempt"
    case listenAddressesChanged = "ListenAddressesChanged"
    
    // --- Folder Operations ---
    case folderRejected          = "FolderRejected"
    case folderScanProgress      = "FolderScanProgress"
    case folderSummary           = "FolderSummary"
    case folderCompletion        = "FolderCompletion"
    case folderErrors            = "FolderErrors"
    case folderPaused            = "FolderPaused"
    case folderResumed           = "FolderResumed"
    case folderWatchStateChanged = "FolderWatchStateChanged"
    
    // --- Item/File Operations ---
    case itemStarted            = "ItemStarted"
    case itemFinished           = "ItemFinished"
    case localChangeDetected    = "LocalChangeDetected"
    case remoteChangeDetected   = "RemoteChangeDetected"
    case localIndexUpdated      = "LocalIndexUpdated"
    case remoteIndexUpdated     = "RemoteIndexUpdated"
    case metadataIndexFinished  = "MetadataIndexFinished"
    case downloadProgress       = "DownloadProgress"
    
    // --- Device Operations ---
    case deviceConnected        = "DeviceConnected"
    case deviceDisconnected     = "DeviceDisconnected"
    case devicePaused           = "DevicePaused"
    case deviceResumed          = "DeviceResumed"
    case deviceRejected         = "DeviceRejected"
    case deviceDiscovered       = "DeviceDiscovered"
    
    // --- Connection & State ---
    case stateChanged           = "StateChanged"
    case staticStatusChanged    = "StaticStatusChanged"
    case xmppStatusChanged      = "XMPPStatusChanged"
    case clusterConfigReceived  = "ClusterConfigReceived"

    /// Fallback case for future API updates
    case unknown = "Unknown"

    // Custom initializer to handle unknown strings gracefully
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if let type = EventType(rawValue: rawValue) {
            self = type
        } else {
            // Log warning to console for debugging
            print("⚠️ [Syncthing] Unknown EventType received: \(rawValue)")
            self = .unknown
        }
    }
}

/// Data for ItemStarted and ItemFinished events
public struct ItemEventData: Codable {
    public let item: String
    public let folder: String
    public let type: String       // e.g., "file", "dir"
    public let action: String     // e.g., "update", "delete"
    public let error: String?     // Only present in ItemFinished if it failed
}

/// Data for FolderSummary events
public struct FolderSummaryData: Codable {
    public let folder: String
    public let summary: SummaryStats
    
    public struct SummaryStats: Codable {
        public let globalBytes: Int64
        public let localBytes: Int64
        public let needBytes: Int64
        public let state: FolderState
    }
}

/// Data for DeviceConnected / Disconnected events
public struct DeviceEventData: Codable {
    /// The Device ID (mapped from "id")
    public let deviceID: String
    
    /// The network address (mapped from "address" or "addr")
    public let address: String?
    
    /// The connection type (e.g., "tcp-client")
    public let type: String?

    enum CodingKeys: String, CodingKey {
        case deviceID = "id"
        case address = "address"
        case addr = "addr" // Syncthing occasionally toggles between 'addr' and 'address'
        case type = "type"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // The ID is mandatory
        self.deviceID = try container.decode(String.self, forKey: .deviceID)
        
        // Address can be under "address" or "addr"
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
                    ?? container.decodeIfPresent(String.self, forKey: .addr)
        
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
    }
    
    public func encode(to encoder: Encoder) throws { /* Implementation if needed */ }
}

public struct FolderConfiguration: Codable, Identifiable {
    public let id: String
    public let label: String
    public let path: String
    public let type: FolderType
    public let paused: Bool
    public let filesystemType: String
    
    // Conforming to Identifiable for SwiftUI
    public var identifier: String { id }
}

public enum FolderType: String, Codable {
    case sendreceive = "sendreceive"
    case sendonly = "sendonly"
    case receiveonly = "receiveonly"
    case receiveencrypted = "receiveencrypted"
}

public enum FolderState: String, Codable, CaseIterable {
    /// Folder is currently being scanned for changes
    case scanning = "scanning"
    
    /// Folder is waiting for a scan or sync to start
    case idle = "idle"
    
    /// Files are currently being transferred or updated
    case syncing = "syncing"
    
    /// Folder is waiting for a peer to become available or for a cooldown
    case waiting = "waiting"
    
    /// An error occurred (e.g., permissions, missing path)
    case error = "error"
    
    /// This state is sent when Syncthing is starting up or the folder is being initialized
    case unknown = "unknown"

    // MARK: - UI Helpers
    
    /// Returns a user-friendly string for the UI
    var localizedDescription: String {
        switch self {
        case .scanning: return "Scanning Files..."
        case .idle:     return "Up to Date"
        case .syncing:  return "Syncing..."
        case .waiting:  return "Waiting"
        case .error:    return "Folder Error"
        case .unknown:  return "Initializing"
        }
    }

    /// Returns a color associated with the state for badges or progress bars
    /*
    var themeColor: Color {
        switch self {
        case .idle:     return .green
        case .syncing:  return .blue
        case .scanning: return .purple
        case .waiting:  return .orange
        case .error:    return .red
        case .unknown:  return .gray
        }
    }
    */
    
    /// Returns a SF Symbol name for the state icon
    var iconName: String {
        switch self {
        case .scanning: return "magnifyingglass"
        case .idle:     return "checkmark.circle.fill"
        case .syncing:  return "arrow.triangle.2.circlepath"
        case .waiting:  return "clock.fill"
        case .error:    return "exclamationmark.triangle.fill"
        case .unknown:  return "questionmark.circle"
        }
    }
}

extension FolderState {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = FolderState(rawValue: rawValue) ?? .unknown
    }
}

public struct FolderStatus: Codable {
    public let state: FolderState
    public let errors: Int
    public let globalBytes: Int64
    public let localBytes: Int64
    public let needBytes: Int64
    public let inSyncBytes: Int64
    
    public var progressPercent: Double {
        guard globalBytes > 0 else { return 1.0 }
        let progress = Double(inSyncBytes) / Double(globalBytes)
        return progress * 100
    }
}

// MARK: - Type-Safe Dynamic Data Helper
public struct AnyCodable: Codable {
    public let value: Any

        public init(_ value: Any) { self.value = value }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            // 1. Check for Null first
            if container.decodeNil() {
                self.value = NSNull()
            }
            // 2. Check for standard types
            else if let str = try? container.decode(String.self) { self.value = str }
            else if let int = try? container.decode(Int.self) { self.value = int }
            else if let double = try? container.decode(Double.self) { self.value = double }
            else if let bool = try? container.decode(Bool.self) { self.value = bool }
            else if let dict = try? container.decode([String: AnyCodable].self) {
                self.value = dict.mapValues { $0.value }
            }
            else if let array = try? container.decode([AnyCodable].self) {
                self.value = array.map { $0.value }
            }
            else {
                self.value = NSNull() // Fallback instead of throwing
            }
        }

    public func encode(to encoder: Encoder) throws { /* Implementation if needed */ }
}
