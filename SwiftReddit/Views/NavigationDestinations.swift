//
//  NavigationDestinations.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

extension View {
    func navigationDestinations() -> some View {
        @Environment(AppConfig.self) var config
        
        return self
            .navigationDestination(for: PostListingId.self) { listingId in
                PostsList(listingId: listingId)
            }
            .navigationDestination(for: Post.self) { post in
                PostDetail(post: post)
            }
            .navigationDestination(for: LinkMetadata.self) { meta in
                BasicWebview(linkMeta: meta)
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
