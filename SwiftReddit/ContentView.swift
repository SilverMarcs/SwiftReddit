//
//  ContentView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct ContentView: View {
    @Namespace private var imageNS
    @Namespace private var videoNS
    
    var body: some View {
        TabView {
            Tab("Posts", systemImage: "doc.text.image") {
                HomeTab()
                    .environment(\.imageNS, imageNS)
                    .environment(\.videoNS, videoNS)
            }
            
            Tab("Profile", systemImage: "person.fill") {
                ProfileTab()
                    .environment(\.imageNS, imageNS)
                    .environment(\.videoNS, videoNS)
            }
            
            Tab(role: .search) {
                SearchTab()
                    .environment(\.imageNS, imageNS)
                    .environment(\.videoNS, videoNS)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        #if !os(macOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
        .overlay {
            FullscreenVideoOverlay()
                .environment(\.videoNS, videoNS)
        }
        .overlay {
            FullscreenImageOverlay()
                .environment(\.imageNS, imageNS)
        }
    }
}

#Preview {
    ContentView()
}
