//
//  HomeTab.swift
//  SwiftReddit
//
//  Created by Winston Team on 18/06/25.
//

import SwiftUI

struct HomeTab: View {
    @Environment(AppConfig.self) var config
    var initialSubreddit: PostListingId = ""
    
    var body: some View {
        @Bindable var config = config
        
        NavigationStack(path: $config.path) {
            PostsList(subreddit: initialSubreddit)
                .navigationDestinations()
        }
    }
}

#Preview {
    HomeTab()
}
