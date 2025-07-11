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
            .navigationDestination(for: PostNavigation.self) { postNavigation in
                PostDetailView(postNavigation: postNavigation)
            }
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
            }
            .navigationDestination(for: ImageModalData.self) { imageData in
                ImageModal(images: imageData.images)
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .inbox:
                    InboxView()
                case .message(let mesasage):
                    MessageDetailView(message: mesasage)
                }
            }
    }
}

enum Destination: Hashable {
    case inbox
    case message(Message)
}
