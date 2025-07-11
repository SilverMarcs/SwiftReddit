//
//  PostDetail.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetailView: View {
    @Environment(Nav.self) var nav
    
    @State private var post: Post?
    @State private var comments: [Comment] = []
    @State private var flatComments: [FlatComment] = []
    @State private var collapsedCommentIds: Set<String> = []
    @State private var isLoading = true
    @State private var sortOption: CommentSortOption = .confidence {
        didSet {
            comments = []
            flatComments = []
        }
    }
    
    let postNavigation: PostNavigation
    
    init(post: Post) {
        self.postNavigation = PostNavigation(from: post)
        self._post = State(initialValue: post)
    }
    
    init(postNavigation: PostNavigation) {
        self.postNavigation = postNavigation
    }
    
    @State var scrollPosition = ScrollPosition(idType: Comment.ID.self)

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if let post = post {
                    PostView(post: post, isCompact: false)
                    Divider()
                }
                
                if isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, minHeight: 200)
                    
                } else if !flatComments.isEmpty {
                    Text("Comments")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 15)

                    ForEach(flatComments) { comment in
                        VStack(spacing: 8) {
                            Divider()
                            
                            FlatCommentView(comment: comment) { commentId in
                                toggleCommentCollapse(commentId)
                            }
                        }
                    }
                }
            }
            .scenePadding(.horizontal)
            .scrollTargetLayout()
        }
        .scrollPosition($scrollPosition)
        .task(id: sortOption) {
            await loadComments()
        }
        .refreshable {
            await loadComments(force: true)
        }
        .navigationTitle(post?.subreddit.displayNamePrefixed ?? "Post")
        .navigationSubtitle(post?.numComments.formatted.appending(" comments") ?? "Loading...")
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

    private func loadComments(force: Bool = false) async {
        // If not forced and comments already exist, return early
        if !force && !comments.isEmpty {
            return
        }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        // Determine which subreddit and post ID to use
        let subredditName: String
        let postId: String
        
        if let post = post {
            // Use existing post data
            subredditName = post.subreddit.displayName
            postId = post.id
        } else if let navSubreddit = postNavigation.subreddit {
            // Use navigation data
            subredditName = navSubreddit
            postId = postNavigation.postId
        } else {
            // Can't proceed without subreddit info
            return
        }
        
        if let result = await RedditAPI.shared.fetchPostWithComments(
            subreddit: subredditName,
            postID: postId,
            sort: sortOption
        ) {
            // Extract post, comments, and after token
            let (fetchedPost, fetchedComments, _) = result
            
            // Update post if we didn't have it before
            if force, let fetchedPost = fetchedPost {
                post = fetchedPost
            }
            else if post == nil, let fetchedPost = fetchedPost {
                post = fetchedPost
            }
            
            comments = fetchedComments
            updateFlatComments()
            
            // Scroll to specific comment if coming from inbox
            if let commentId = postNavigation.commentId {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                withAnimation {
                    scrollPosition = .init(id: commentId, anchor: .bottom)
                }
            }
            
        } else {
            print("PostDetailView: Failed to fetch post with comments")
        }
    }
    
    private func updateFlatComments() {
        flatComments = Comment.flattenComments(comments, collapsedIds: collapsedCommentIds)
    }
    
    private func toggleCommentCollapse(_ commentId: String) {
        if collapsedCommentIds.contains(commentId) {
            collapsedCommentIds.remove(commentId)
        } else {
            collapsedCommentIds.insert(commentId)
        }
        updateFlatComments()
    }
}
