import SwiftUI

struct SimpleFeed: View {
    @State private var posts: [LightweightPost] = []
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var error: String?
    @State private var after: String?
    @State private var hasMorePosts = true
    
    let subreddit: Subreddit
    
    var body: some View {
        NavigationView {
            Group {
                if posts.isEmpty && isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading posts...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                } else if posts.isEmpty && error != nil {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Posts")
                            .font(.headline)
                        
                        if let error = error {
                            Text(error)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button("Retry") {
                            Task {
                                await loadPosts()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(posts) { post in
                                LightweightPostView(post: post)
                                    .onAppear {
                                        // Load more when we reach the last few posts
                                        if post.id == posts.suffix(3).first?.id {
                                            Task {
                                                await loadMorePosts()
                                            }
                                        }
                                    }
                            }
                            
                            // Loading more indicator
                            if isLoadingMore && hasMorePosts {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Loading more...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            // End of posts indicator
                            if !hasMorePosts && !posts.isEmpty {
                                Text("No more posts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .refreshable {
                        await refreshPosts()
                    }
                }
            }
            .navigationTitle(subreddit.displayName)
            .navigationBarTitleDisplayMode(.large)
            .task {
                if posts.isEmpty {
                    await loadPosts()
                }
            }
        }
    }
    
    @MainActor
    private func loadPosts() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let result = try await subreddit.fetchLightweightPosts(limit: 25)
            posts = result.posts
            after = result.after
            hasMorePosts = result.after != nil
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    private func loadMorePosts() async {
        guard !isLoadingMore, hasMorePosts, let after = after else { return }
        
        isLoadingMore = true
        
        do {
            let result = try await subreddit.fetchLightweightPosts(limit: 25, after: after)
            posts.append(contentsOf: result.posts)
            self.after = result.after
            hasMorePosts = result.after != nil
        } catch {
            // Silently fail for now - could show a toast or retry button
            print("Failed to load more posts: \(error)")
        }
        
        isLoadingMore = false
    }
    
    @MainActor
    private func refreshPosts() async {
        after = nil
        hasMorePosts = true
        await loadPosts()
    }
}
