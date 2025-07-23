//
//  SwiftDditApp.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 15/06/2025.
//

import SwiftUI
import AVKit

@main
struct SwiftDditApp: App {
    
    var body: some Scene {
        #if os(macOS)
        Window("SwiftDdit", id: "SwiftDdit") {
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
