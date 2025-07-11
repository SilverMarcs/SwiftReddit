//
//  ContentView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct ContentView: View {
    @State private var navHome = Nav()
    @State private var navProfile = Nav()
    @State private var navSearch = Nav()
    
    @Namespace private var imageZoomNamespace
    
    var body: some View {
        TabView {
            Tab("Posts", systemImage: "doc.text.image") {
                HomeTab()
                    .environment(navHome)
                    .environment(\.imageZoomNamespace, imageZoomNamespace)
            }
            
            Tab("Profile", systemImage: "person.fill") {
                ProfileView()
                    .environment(navProfile)
                    .environment(\.imageZoomNamespace, imageZoomNamespace)
            }
            
            Tab(role: .search) {
                SearchTab()
                    .environment(navSearch)
                    .environment(\.imageZoomNamespace, imageZoomNamespace)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        #if !os(macOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
        .overlay {
            FullscreenVideoOverlay()
        }
    }
}

#Preview {
    ContentView()
}
