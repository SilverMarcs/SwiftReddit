//
//  PostDetail.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetailView: View {
    @Environment(Nav.self) var nav
    
    let post: Post
    
    @State private var comments: [Comment] = []
    @State private var isLoading = true
    @State private var sortOption: CommentSortOption = .confidence {
        didSet {
            comments = []
        }
    }
    
    @State private var showingReplySheet = false
    @State private var replyTarget: ReplySheet.ReplyTarget
    
    init(post: Post) {
        self.post = post
        self._replyTarget = State(initialValue: .post(post))
    }


    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                PostView(post: post, isCompact: false)
                
                if isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if !comments.isEmpty {
                    Text("Comments")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    ForEach(comments) { comment in
                        CommentView(comment: comment, onToggleCollapse: { updatedComment in
                            updateComment(updatedComment)
                        }, onReply: { comment in
                            replyTarget = .comment(comment)
                            showingReplySheet = true
                        }, isTopLevel: true)
                        .padding(.horizontal, 5)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Spacer()
                
                Button {
                    replyTarget = .post(post)
                    showingReplySheet = true
                } label: {
                    Label("Reply", systemImage: "arrowshape.turn.up.backward.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .buttonBorderShape(.circle)
            }
            .padding()
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showingReplySheet) {
            ReplySheet(
                target: replyTarget,
                onReply: handleReply
            )
            .presentationDetents([.medium])
        }
        .task(id: sortOption) {
            await loadComments()
        }
        .refreshable {
            await loadComments(force: true)
        }
        .navigationTitle(post.subreddit.displayNamePrefixed)
        .navigationSubtitle(post.numComments.formatted + " comments")
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
    
    private func handleReply(_ text: String, _ fullname: String) {
        Task {
            let success = await RedditAPI.shared.newReply(text, fullname)
            if success == true {
                // Refresh comments after successful reply
                await loadComments(force: true)
            }
        }
    }
    
    private func loadComments(force: Bool = false) async {
        // If not forced and comments already exist, return early
        if !force && !comments.isEmpty {
            return
        }
        
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
