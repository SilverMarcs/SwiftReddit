//
//  CommentActionsView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct CommentActionsView: View {
    let comment: Comment
    @State private var likes: Bool?
    @State private var upsCount: Int
    
    init(comment: Comment) {
        self.comment = comment
        self._likes = State(initialValue: comment.likes)
        self._upsCount = State(initialValue: comment.ups)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: { vote(action: .up) }) {
                Image(systemName: "arrow.up")
                    .font(.subheadline)
                    .foregroundStyle(likes == true ? .indigo : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(upsCount.formatted())
                .contentTransition(.numericText())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(likes == true ? .indigo : likes == false ? .red : .secondary)
            
            Button(action: { vote(action: .down) }) {
                Image(systemName: "arrow.down")
                    .font(.subheadline)
                    .foregroundStyle(likes == false ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .id(comment.id)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.background.secondary, in: .rect(cornerRadius: 14))
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
            let success = await RedditAPI.shared.voteComment(action, id: comment.fullname)

            // Revert on failure
            if success != true {
                likes = initialLikes
                upsCount = initialUpsCount
            }
        }
    }
}
