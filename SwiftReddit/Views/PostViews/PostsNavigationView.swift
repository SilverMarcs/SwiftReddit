//
//  PostsNavigationView.swift
//  SwiftReddit
//
//  Created by Winston Team on 18/06/25.
//

import SwiftUI

struct PostsNavigationView: View {
    @Environment(AppConfig.self) var config
    var initialSubreddit: Subreddit = .home
    
    var body: some View {
        @Bindable var config = config
        
        NavigationStack(path: $config.path) {
            PostsList(subreddit: initialSubreddit)
                .navigationDestination(for: Post.self) { post in
                    PostDetail(post: post)
                }
                .navigationDestination(for: Subreddit.self) { subreddit in
                    PostsList(subreddit: subreddit)
                }
                .navigationDestination(for: LinkMetadata.self) { meta in
                    BasicWebview(linkMeta: meta)
                }
        }
        .environment(\.openURL, OpenURLAction { url in
            let linkMetadata = LinkMetadata(
                url: url.absoluteString,
                domain: url.host ?? "Unknown",
                thumbnailURL: nil
            )
            
            config.path.append(linkMetadata)
            
            return .handled
        })
    }
}

#Preview {
    PostsNavigationView()
}
