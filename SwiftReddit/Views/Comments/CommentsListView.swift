//
//  CommentsListView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct CommentsListView: View {
    let post: Post
    let sortOption: CommentSortOption
    @State private var comments: [Comment] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(errorMessage)
            } else if comments.isEmpty {
                emptyView
            } else {
                commentsList
            }
        }
        .task {
            await loadComments()
        }
        .task(id: sortOption) {
            await loadComments()
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .controlSize(.large)
            .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await loadComments()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var emptyView: some View {
        Text("No comments yet")
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    @ViewBuilder
    private var commentsList: some View {
        Text("Comments")
            .font(.title3)
            .fontWeight(.bold)
            .padding(.leading)
        
        ForEach(comments) { comment in
            CommentView(comment: comment, onToggleCollapse: { updatedComment in
                updateComment(updatedComment)
            }, isTopLevel: true)
            .padding(.horizontal, 5)
        }
    }
    
    private func loadComments() async {
        isLoading = true
        errorMessage = nil
    
        if let result = await RedditAPI.shared.fetchPostWithComments(
            subreddit: post.subreddit.displayName,
            postID: post.id,
            sort: sortOption
        ) {
            await MainActor.run {
                self.comments = result.0
                self.isLoading = false
            }
        } else {
            await MainActor.run {
                self.errorMessage = "Unable to fetch comments"
                self.isLoading = false
            }
        }
    }
    
    private func updateComment(_ updatedComment: Comment) {
        // Find and update the comment in the array
        if let index = comments.firstIndex(where: { $0.id == updatedComment.id }) {
            comments[index] = updatedComment
        } else {
            // If not found in top level, recursively search in children
            updateCommentRecursively(&comments, updatedComment)
        }
    }
    
    private func updateCommentRecursively(_ comments: inout [Comment], _ updatedComment: Comment) {
        for index in comments.indices {
            if comments[index].id == updatedComment.id {
                comments[index] = updatedComment
                return
            }
            updateCommentRecursively(&comments[index].children, updatedComment)
        }
    }
}
