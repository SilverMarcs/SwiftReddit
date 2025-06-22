//
//  SwiftRedditApp.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 15/06/2025.
//

import SwiftUI

@main
struct SwiftRedditApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("ImageCache")
        let cache = URLCache(
            memoryCapacity: 50_000_000, // 50 MB
            diskCapacity: 200_000_000,  // 100 MB
            directory: diskCacheURL
        )
        URLCache.shared = cache
    }
}
