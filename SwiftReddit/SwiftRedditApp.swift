//
//  SwiftRedditApp.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 15/06/2025.
//

import SwiftUI
import AVKit
import Kingfisher

@main
struct SwiftRedditApp: App {
    
    var body: some Scene {
        #if os(macOS)
        Window("SwiftReddit", id: "SwiftReddit") {
            ContentView()
                .onAppear {
                   NSWindow.allowsAutomaticWindowTabbing = false
               }
        }
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
    
    init() {
        ImageCache.default.memoryStorage.config.totalCostLimit = 1024 * 1024 * 60 // 60 MB
        ImageCache.default.diskStorage.config.sizeLimit = 1024 * 1024 * 200 // 300 MB
        ImageCache.default.diskStorage.config.expiration = .days(2) // 2 day
        
        #if !os(macOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }
}
