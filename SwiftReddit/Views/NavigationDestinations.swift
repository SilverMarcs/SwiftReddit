//
//  NavigationDestinations.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

extension View {
    func navigationDestinations() -> some View {
        return self
            .navigationDestination(for: PostFeedType.self) { feedType in
                PostsList(feedType: feedType)
            }
            .navigationDestination(for: Post.self) { post in
                PostDetail(post: post)
            }
            .navigationDestination(for: LinkMetadata.self) { meta in
                BasicWebview(linkMeta: meta)
            }
            .navigationDestination(for: ImageModalData.self) { imageData in
                ImageModal(images: imageData.images)
            }
    }
}
