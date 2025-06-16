import Foundation

/// A minimal subreddit model for feed fetching
struct Subreddit: Identifiable, Hashable {
    let id: String
    let name: String
    let displayName: String
    let subscribers: Int?
    
    init(name: String) {
        self.id = name.lowercased()
        self.name = name.lowercased()
        self.displayName = name
        self.subscribers = nil
    }
    
    init(from json: [String: Any]) {
        let data = json["data"] as? [String: Any] ?? [:]
        
        self.id = data["id"] as? String ?? ""
        self.name = data["display_name"] as? String ?? ""
        self.displayName = data["display_name"] as? String ?? ""
        self.subscribers = data["subscribers"] as? Int
    }
}

// MARK: - Static instances
extension Subreddit {
    static let home = Subreddit(name: "Home")
    static let popular = Subreddit(name: "Popular")
    static let all = Subreddit(name: "All")
}
