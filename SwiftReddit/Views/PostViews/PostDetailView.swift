//
//  PostDetail.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetailView: View {
    @Environment(Nav.self) var nav
    
    let postNavigation: PostNavigation
    
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
    
    @State var scrollPosition = ScrollPosition(idType: Comment.ID.self)
    @State private var showCommentSheet = false
    
    init(post: Post) {
        self.postNavigation = PostNavigation(from: post)
        self._post = State(initialValue: post)
    }
    
    init(postNavigation: PostNavigation) {
        self.postNavigation = postNavigation
    }


    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if let post = post {
                    PostView(
                        post: post,
                        isCompact: false,
                        onReplyTap: { showCommentSheet = true }
                    )
                    
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
                        .padding(.vertical, 10)

                    ForEach(flatComments) { comment in
                        VStack(spacing: 8) {
                            if comment.depth == 0 && comment.id != flatComments.first?.id {
                                Rectangle()
                                    .fill(.background.secondary)
                                    .frame(height: 6)
                                    .padding(.horizontal, -15)
                            } else if comment.id != flatComments.first?.id {
                                Divider()
                            }
                            
                            FlatCommentView(comment: comment) { commentId in
                                toggleCommentCollapse(commentId)
                            }
                            .environment(\.addOptimisticComment, addOptimisticComment)
                        }
                    }
                }
            }
            .scenePadding(.horizontal)
            .scenePadding(.bottom)
            .scrollTargetLayout()
        }
        .scrollPosition($scrollPosition)
        .task(id: sortOption) {
            // Load if we don't have a post or if comments are empty
            if post == nil || comments.isEmpty {
                await loadComments()
            }
        }
        .refreshable {
            await loadComments()
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
        .sheet(isPresented: $showCommentSheet) {
            if let post = post {
                ReplySheet(parentId: post.id, isTopLevel: true) { text, postId in
                    addOptimisticTopLevelComment(text: text, postId: postId)
                }
            }
        }
    }

    private func loadComments() async {
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
            if let fetchedPost = fetchedPost {
                post = fetchedPost
            }
            
            comments = fetchedComments
            updateFlatComments()
            
            // Scroll to specific comment if coming from inbox
            if let commentId = postNavigation.commentId {
                try? await Task.sleep(nanoseconds: 250_000_000)
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
    
    private func addOptimisticComment(text: String, parentId: String) {
        let fakeId = "temp_\(UUID().uuidString)"
        
        // Find the parent comment in flatComments to get its depth
        guard let parentIndex = flatComments.firstIndex(where: { $0.id == parentId }) else {
            print("Could not find parent comment with id: \(parentId)")
            return
        }
        
        let parentComment = flatComments[parentIndex]
        
        // Create optimistic flat comment
        let optimisticFlatComment = FlatComment(
            id: fakeId,
            author: CredentialsManager.shared.credential?.userName ?? "You",
            body: text,
            created: Date().timeIntervalSince1970,
            score: 1,
            ups: 1,
            depth: parentComment.depth + 1,
            parentID: "t1_\(parentId)",
            isSubmitter: false,
            authorFlairText: nil,
            authorFlairBackgroundColor: nil,
            distinguished: nil,
            stickied: false,
            likes: true,
            isVisible: true,
            hasChildren: false,
            isCollapsed: false,
            childCount: 0
        )
        
        // Insert the new comment right after the parent comment
        flatComments.insert(optimisticFlatComment, at: parentIndex + 1)
        
        // Scroll to the new comment
        withAnimation {
            scrollPosition = .init(id: fakeId)
        }
        
        // Fire off the network request in the background
        Task {
            _ = await RedditAPI.shared.replyToComment(text: text, parentFullname: "t1_\(parentId)")
        }
    }
    
    private func addOptimisticTopLevelComment(text: String, postId: String) {
        let fakeId = "temp_\(UUID().uuidString)"
        
        // Create optimistic top-level comment
        let optimisticFlatComment = FlatComment(
            id: fakeId,
            author: CredentialsManager.shared.credential?.userName ?? "You",
            body: text,
            created: Date().timeIntervalSince1970,
            score: 1,
            ups: 1,
            depth: 0,
            parentID: "t3_\(postId)",
            isSubmitter: false,
            authorFlairText: nil,
            authorFlairBackgroundColor: nil,
            distinguished: nil,
            stickied: false,
            likes: true,
            isVisible: true,
            hasChildren: false,
            isCollapsed: false,
            childCount: 0
        )
        
        // Insert the new comment at the top of the list
        flatComments.insert(optimisticFlatComment, at: 0)
        
        // Scroll to the new comment with animation
        withAnimation {
            scrollPosition = .init(id: fakeId)
        }
        
        // Fire off the network request in the background
        Task {
            _ = await RedditAPI.shared.replyToComment(text: text, parentFullname: "t3_\(postId)")
        }
    }
}
