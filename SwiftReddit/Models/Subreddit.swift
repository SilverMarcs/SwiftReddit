//
//  Subreddit.swift
//  SwiftReddit
//
//  Created on 18/06/2025.
//

import Foundation

struct Subreddit: Identifiable, Hashable {
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    // Convenience initializer for home feed
    static let home = Subreddit(id: "")
    
    var displayName: String {
        return id.isEmpty ? "Home" : "r/\(id)"
    }
    
    var isHome: Bool {
        return id.isEmpty
    }
}
