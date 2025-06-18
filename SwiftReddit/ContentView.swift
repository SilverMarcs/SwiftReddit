//
//  ContentView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab: Tabs = .posts
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Posts", systemImage: "doc.text.image", value: .posts) {
                PostsNavigationView()
            }
            
            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                SettingsView()
            }
            
            Tab(value: .search, role: .search) {
                SearchTab()
            }
                
        }
        #if !os(macOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
    }
}

enum Tabs: Hashable {
    case posts
    case settings
    case search
}

#Preview {
    ContentView()
}
