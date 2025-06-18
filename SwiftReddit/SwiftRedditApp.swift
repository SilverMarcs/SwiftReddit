//
//  SwiftRedditApp.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 15/06/2025.
//

import SwiftUI

@main
struct SwiftRedditApp: App {
    @State private var config = AppConfig()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(config)
        }
    }
}
