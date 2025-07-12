import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private let service = "com.mush.swifttube.SwiftTube"
    
    private let appIDKey = "reddit_app_id"
    private let appSecretKey = "reddit_app_secret"
    
    private init() {}
    
    func save(key: String, data: String) {
        let keyData = data.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: keyData
        ]
        
        SecItemDelete(query as CFDictionary) // Delete existing item if it exists
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = unsafe SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - App Credentials Persistence
    func saveAppID(_ appID: String) {
        save(key: appIDKey, data: appID)
    }
    
    func saveAppSecret(_ appSecret: String) {
        save(key: appSecretKey, data: appSecret)
    }
    
    func loadAppID() -> String? {
        load(key: appIDKey)
    }
    
    func loadAppSecret() -> String? {
        load(key: appSecretKey)
    }
}
