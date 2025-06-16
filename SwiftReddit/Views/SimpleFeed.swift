////
////  SimpleFeed.swift
////  winston
////
////  Created by Winston Team on 16/06/25.
////
//
//import SwiftUI
//
//struct SimpleFeed: View {
//    let subreddit: Subreddit
//    
//    @State private var posts: [LightweightPost] = []
//    @State private var loading = false
//    @State private var lastPostAfter: String? = nil
//    @State private var hasMorePosts = true
//    @State private var sort: SubListingSortOption = .best
//    
//    var body: some View {
//        List {
//            ForEach(posts) { post in
//                PostRowView(post: post)
//                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
//                    .onAppear {
//                        // Load more when we reach the last few posts
//                        if post.id == posts.last?.id {
//                            loadMorePosts()
//                        }
//                    }
//            }
//            .listRowSeparator(.hidden)
//            
//            if loading {
//                HStack {
//                    Spacer()
//                    ProgressView()
//                        .padding()
//                    Spacer()
//                }
//                .listRowSeparator(.hidden)
//            }
//            
//            if !hasMorePosts && !posts.isEmpty {
//                Text("No more posts")
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding()
//                    .listRowSeparator(.hidden)
//            }
//        }
//        .listStyle(.plain)
//        .refreshable {
//            await refreshFeed()
//        }
//        .navigationTitle(titleFormatted)
//        .navigationBarTitleDisplayMode(.large)
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Menu {
//                    ForEach(SubListingSortOption.allCases) { option in
//                        Button(option.displayName) {
//                            sort = option
//                            Task {
//                                await refreshFeed()
//                            }
//                        }
//                    }
//                } label: {
//                    Image(systemName: "arrow.up.arrow.down")
//                }
//            }
//        }
//        .onAppear {
//            if posts.isEmpty {
//                loadInitialPosts()
//            }
//        }
//    }
//    
//    private var titleFormatted: String {
//        switch subreddit.id {
//        case "home":
//            return "Home"
//        case "all":
//            return "r/all"
//        case "popular":
//            return "r/popular"
//        default:
//            return subreddit.data?.display_name_prefixed ?? "r/\(subreddit.id)"
//        }
//    }
//    
//    private func loadInitialPosts() {
//        guard !loading else { return }
//        
//        loading = true
//        lastPostAfter = nil
//        hasMorePosts = true
//        
//        Task {
//            await fetchPosts(isRefresh: true)
//        }
//    }
//    
//    private func loadMorePosts() {
//        guard !loading && hasMorePosts else { return }
//        
//        loading = true
//        Task {
//            await fetchPosts(isRefresh: false)
//        }
//    }
//    
//    private func refreshFeed() async {
//        lastPostAfter = nil
//        hasMorePosts = true
//        await fetchPosts(isRefresh: true)
//    }
//    
//    private func fetchPosts(isRefresh: Bool) async {
//        let result = await subreddit.fetchPosts(
//            sort: sort,
//            after: isRefresh ? nil : lastPostAfter,
//            limit: 10
//        )
//        
//        await MainActor.run {
//            loading = false
//            
//            if let (newPosts, newAfter) = result, let newPosts = newPosts {
//                if isRefresh {
//                    posts = newPosts
//                } else {
//                    posts.append(contentsOf: newPosts)
//                }
//                
//                lastPostAfter = newAfter
//                hasMorePosts = !newPosts.isEmpty && newAfter != nil
//                
//            } else {
//                hasMorePosts = false
//            }
//        }
//    }
//}
//
//struct PostRowView: View {
//    let post: LightweightPost
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            // Title
//            Text(post.title)
//                .font(.headline)
//                .lineLimit(3)
//            
//            // Metadata row
//            HStack {
//                Text("r/\(post.subreddit)")
//                    .font(.caption)
//                    .foregroundColor(.blue)
//                
//                Text("•")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                Text("u/\(post.author)")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                Text("•")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                Text(post.timeAgo)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                Spacer()
//            }
//            
//            // Stats row
//            HStack {
//                // Upvotes
//                HStack(spacing: 4) {
//                    Image(systemName: "arrow.up")
//                        .font(.caption)
//                    Text(post.formattedUps)
//                        .font(.caption)
//                }
//                .foregroundColor(.orange)
//                
//                Text("•")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                // Comments
//                HStack(spacing: 4) {
//                    Image(systemName: "bubble.left")
//                        .font(.caption)
//                    Text(post.formattedComments)
//                        .font(.caption)
//                }
//                .foregroundColor(.secondary)
//                
//                Spacer()
//                
//                // Media indicator
//                if post.mediaType.hasMedia {
//                    Image(systemName: post.mediaType.mediaIcon)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//                
//                // NSFW indicator
//                if post.isNSFW {
//                    Text("NSFW")
//                        .font(.caption2)
//                        .padding(.horizontal, 4)
//                        .padding(.vertical, 2)
//                        .background(Color.red.opacity(0.2))
//                        .foregroundColor(.red)
//                        .clipShape(Capsule())
//                }
//            }
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//#Preview {
//    NavigationView {
//        SimpleFeed(subreddit: Subreddit(id: "home"))
//    }
//}
