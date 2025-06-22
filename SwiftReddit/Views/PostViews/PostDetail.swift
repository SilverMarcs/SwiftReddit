//
//  PostDetail.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetail: View {
    @Environment(Nav.self) var nav
    
    let post: Post
    
    @State private var comments: [Comment] = []
    @State private var isLoading = true
    @State private var sortOption: CommentSortOption = .confidence

    var body: some View {
        // TODO: use list
        ScrollView {
            LazyVStack(alignment: .leading) {
                PostView(post: post, isHomeFeed: !cameFromSubredditPage, isCompact: false)
                
                if isLoading {
                    loadingView
                } else {
                    commentsList
                }
            }
        }
        .task {
            await loadComments()
        }
        .task(id: sortOption) {
            await loadComments()
        }
        .navigationTitle(post.subreddit.displayNamePrefixed)
        .navigationSubtitle(post.formattedComments + " comments")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(CommentSortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            Label(option.displayName, systemImage: option.iconName)
                                .tag(option)
                        }
                    }
                } label: {
                    Label("Sort by", systemImage: sortOption.iconName)
                        .labelStyle(.iconOnly)
                }
                .tint(.accent)
            }
        }
    }
    
    // Check if we came from a subreddit page (path length > 1 means we have Subreddit -> Post)
    private var cameFromSubredditPage: Bool {
        nav.path.count > 1
    }
    
    
    private var loadingView: some View {
        ProgressView()
            .controlSize(.large)
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
        guard comments.isEmpty || isLoading else { return }
        isLoading = true
    
        if let result = await RedditAPI.shared.fetchPostWithComments(
            subreddit: post.subreddit.displayName,
            postID: post.id,
            sort: sortOption
        ) {
            comments = result.0
            isLoading = false
        } else {
            isLoading = false
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

//#Preview {
//    PostDetail()
//}
