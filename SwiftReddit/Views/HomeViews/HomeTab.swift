//
//  HomeTab.swift
//  SwiftReddit
//
//  Created by Winston Team on 18/06/25.
//

import SwiftUI

struct HomeTab: View {
    @Environment(Nav.self) var nav
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            PostsList(feedType: .home)
                .navigationDestinations()
        }
    }
}

#Preview {
    HomeTab()
}
