//
//  ContentView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab: Tabs = .posts
    
    @State private var navHome = Nav()
    @State private var navProfile = Nav()
    @State private var navSearch = Nav()
    @Namespace private var imageZoomNamespace
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Posts", systemImage: "doc.text.image", value: .posts) {
                HomeTab()
                    .environment(navHome)
                    .environment(\.imageZoomNamespace, imageZoomNamespace)
            }
            
            Tab("Profile", systemImage: "person.fill", value: .profile) {
                ProfileView()
                    .environment(navProfile)
                    .environment(\.imageZoomNamespace, imageZoomNamespace)
            }
            
            Tab(value: .search, role: .search) {
                SearchTab()
                    .environment(navSearch)
                    .environment(\.imageZoomNamespace, imageZoomNamespace)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        #if !os(macOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
    }
}

enum Tabs: Hashable {
    case posts
    case profile
    case search
}

#Preview {
    ContentView()
}
