//
//  NavigationDestinations.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

extension View {
    func navigationDestinations() -> some View {
        @Environment(Nav.self) var nav
        
        return self
            .navigationDestination(for: Subreddit.self) { subreddit in
                PostsList(subreddit: subreddit)
            }
            .navigationDestination(for: Post.self) { post in
                PostDetail(post: post)
            }
            .navigationDestination(for: LinkMetadata.self) { meta in
                BasicWebview(linkMeta: meta)
            }
//            .environment(\.openURL, OpenURLAction { url in
//                let linkMetadata = LinkMetadata(
//                    url: url.absoluteString,
//                    domain: url.host ?? "Unknown",
//                    thumbnailURL: nil
//                )
//                
//                nav.path.append(linkMetadata)
//                //                nav.navigateToLink(linkMetadata)
//
//                
//                return .handled
//            })
    }
}
