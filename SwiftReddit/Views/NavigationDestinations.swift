//
//  NavigationDestinations.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

extension View {
    func navigationDestinations(append: @escaping (any Hashable) -> Void) -> some View {
        return self
            .environment(\.appendToPath, { value in
                 append(value)
            })
            .navigationDestination(for: PostFeedType.self) { feedType in
                PostsList(feedType: feedType)
                    .environment(\.appendToPath, append)
            }
            .navigationDestination(for: PostNavigation.self) { postNavigation in
                PostDetailView(postNavigation: postNavigation)
                    .environment(\.appendToPath, append)
            }
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
                    .environment(\.appendToPath, append)
            }
            .navigationDestination(for: Message.self) { message in
                MessageDetailView(message: message)
                    .environment(\.appendToPath, append)
            }
            .navigationDestination(for: InboxDestination.self) { inbox in
                InboxView()
                    .environment(\.appendToPath, append)
            }
            .navigationDestination(for: ImageModalData.self) { imageData in
                ImageModal(imageData: imageData)
                    .environment(\.appendToPath, append)
                    #if !os(macOS)
                    .toolbarVisibility(.hidden, for: .tabBar)
                    .toolbarVisibility(.hidden, for: .navigationBar)
                    #endif
            }
    }
}

struct InboxDestination: Hashable { }
