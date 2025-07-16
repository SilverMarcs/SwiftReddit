//
//  SwiftRedditApp.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 15/06/2025.
//

import SwiftUI
import AVKit

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
        #if !os(macOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }
}
