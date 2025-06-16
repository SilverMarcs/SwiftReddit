//
//  PostsView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct PostsView: View {
    @State private var posts: [LightweightPost] = []
    @State private var isLoading = false
    @State private var loadingMore = false
    @State private var after: String?
    @State private var selectedSort: SubListingSortOption = .best
    @State private var selectedSubreddit = "Home"
    @State private var errorMessage: String?
    
    private let subredditOptions = ["Home", "popular", "all", "AskReddit", "funny", "worldnews", "pics", "gaming"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with subreddit picker and sort options
                VStack(spacing: 12) {
                    HStack {
                        Text("Feed:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Subreddit", selection: $selectedSubreddit) {
                            ForEach(subredditOptions, id: \.self) { subreddit in
                                Text(subreddit).tag(subreddit)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Spacer()
                        
                        Picker("Sort", selection: $selectedSort) {
                            ForEach(SubListingSortOption.allCases) { sort in
                                Text(sort.displayName).tag(sort)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                
                Divider()
                
                // Posts List
                if isLoading && posts.isEmpty {
                    VStack {
                        ProgressView()
                        Text("Loading posts...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if posts.isEmpty {
                    VStack {
                        Text("No posts available")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Pull to refresh or check your credentials")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(posts) { post in
                            PostRowView(post: post)
                                .onAppear {
                                    // Load more when near the end
                                    if post == posts.last {
                                        loadMorePosts()
                                    }
                                }
                        }
                        
                        if loadingMore {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Loading more...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await refreshPosts()
                    }
                }
            }
            .navigationTitle("Posts")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedSubreddit) { _, _ in
            Task {
                await refreshPosts()
            }
        }
        .onChange(of: selectedSort) { _, _ in
            Task {
                await refreshPosts()
            }
        }
        .task {
            await loadInitialPosts()
        }
    }
    
    private func loadInitialPosts() async {
        guard !isLoading else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        await fetchPosts(isRefresh: true)
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func refreshPosts() async {
        await fetchPosts(isRefresh: true)
    }
    
    private func loadMorePosts() {
        guard !loadingMore && !isLoading && after != nil else { return }
        
        Task {
            await MainActor.run {
                loadingMore = true
            }
            
            await fetchPosts(isRefresh: false)
            
            await MainActor.run {
                loadingMore = false
            }
        }
    }
    
    private func fetchPosts(isRefresh: Bool) async {
        let afterParam = isRefresh ? nil : after
        
        let result = if selectedSubreddit == "Home" {
            await RedditAPI.shared.fetchHomeFeed(sort: selectedSort, after: afterParam, limit: 10)
        } else {
            await RedditAPI.shared.fetchSubredditPosts(
                subreddit: selectedSubreddit,
                sort: selectedSort,
                after: afterParam,
                limit: 10
            )
        }
        
        await MainActor.run {
            if let (newPosts, newAfter) = result {
                if isRefresh {
                    self.posts = newPosts
                } else {
                    self.posts.append(contentsOf: newPosts)
                }
                self.after = newAfter
                self.errorMessage = nil
            } else {
                self.errorMessage = "Failed to load posts. Check your connection and credentials."
            }
        }
    }
}

struct PostRowView: View {
    let post: LightweightPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(post.title)
                .font(.headline)
                .lineLimit(3)
            
            // Media view
//            if post.mediaType.hasMedia {
//                LightweightMediaView(mediaType: post.mediaType)
//            }
            
            // Metadata row
            HStack {
                Text("r/\(post.subreddit)")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("u/\(post.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(post.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if post.isNSFW {
                    Text("NSFW")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            // Media indicator and stats row
            HStack {
                if post.mediaType.hasMedia {
                    HStack(spacing: 4) {
                        Image(systemName: post.mediaType.mediaIcon)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if case .gallery(let count, _) = post.mediaType {
                            Text("\(count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if post.linkFlairText != nil {
                    Text(post.linkFlairText!)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.caption)
                        Text(post.formattedUps)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.caption)
                        Text(post.formattedComments)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    PostsView()
}
