//
//  PostActionsView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct PostActionsView: View {
    let post: Post
    @State private var likes: Bool?
    @State private var upsCount: Int

    init(post: Post) {
        self.post = post
        self._likes = State(initialValue: post.likes)
        self._upsCount = State(initialValue: post.ups)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: { vote(action: .up) }) {
                Image(systemName: "arrow.up")
                    .font(.title2)
                    .foregroundStyle(likes == true ? .indigo : .secondary)
            }
            .buttonStyle(.plain)

            Text(upsCount.formatted())
                .contentTransition(.numericText())
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(likes == true ? .indigo : likes == false ? .red : .secondary)

            Button(action: { vote(action: .down) }) {
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundStyle(likes == false ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .fontWeight(.semibold)
    }
    
    
    private func hapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    private func vote(action: RedditAPI.VoteAction) {
        hapticFeedback()

        Task {
            let initialLikes = likes
            let initialUpsCount = upsCount

            // Optimistically update the UI
            switch action {
            case .up:
                likes = (likes == true) ? nil : true // Toggle upvote
                upsCount += (likes == true) ? (initialLikes == nil ? 1 : -1) : -1
            case .down:
                likes = (likes == false) ? nil : false // Toggle downvote
                upsCount += (likes == false) ? (initialLikes == nil ? -1 : 1) : 1
            case .none:
                break
            }

            // Fire and forget API call
            let success = await RedditAPI.shared.vote(action, id: post.fullname)

            if success != true {
                // Revert on failure
                await MainActor.run {
                    likes = initialLikes
                    upsCount = initialUpsCount
                }
            }
        }
    }
}
