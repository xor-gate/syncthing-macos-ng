import Foundation

@propertyWrapper
struct STConfigurationUserDefaults<T: Codable> {
    let key: String
    let defaultValue: T
    var container: UserDefaults = .standard

    var wrappedValue: T {
        get {
            // macOS 12: Standard data retrieval
            guard let data = container.data(forKey: key) else {
                return defaultValue
            }
            
            // Explicitly handle decoding errors to avoid silent failures
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                NSLog("⚠️ [UserDefaults] Decoding error for \(key): \(error)")
                return defaultValue
            }
        }
        set {
            // Explicitly handle encoding
            do {
                let data = try JSONEncoder().encode(newValue)
                container.set(data, forKey: key)
            } catch {
                NSLog("❌ [UserDefaults] Encoding error for \(key): \(error)")
            }
        }
    }
}
