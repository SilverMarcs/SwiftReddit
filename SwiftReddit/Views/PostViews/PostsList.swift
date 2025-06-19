//
//  PostsList.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI
import WebKit

struct PostsList: View {
    @Environment(AppConfig.self) private var config
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var after: String?
    @State private var selectedSort: SubListingSortOption = .best
    
    let listingId: PostListingId
    
    var body: some View {
        List {
            ForEach(posts) { post in
                Button {
                    config.path.append(post)
                } label: {
                    PostView(post: post)
                        .navigationLinkIndicatorVisibility(.hidden)
                }
                .buttonStyle(.plain)
                .listRowInsets(.vertical, 5)
                .listRowInsets(.horizontal, 5)
            }
            .listRowSeparator(.hidden)
            
            Color.clear
                .frame(height: 10)
                .onAppear {
                    if !isLoading && after != nil {
                        loadMorePosts()
                    }
                }
                .listRowSeparator(.hidden)
            
            if after == nil && !isLoading {
                Text("No more posts")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .listRowSeparator(.hidden)
            }
            
            if isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationTitle(listingId.isEmpty ? "Home" : "\(listingId.withSubredditPrefix)")
        .toolbarTitleDisplayMode(.inlineLarge)
        .refreshable {
            await refreshPosts()
        }
        .task {
            await loadInitialPosts()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(SubListingSortOption.allCases) { sort in
                        Button {
                            selectedSort = sort
                            Task {
                                await refreshPosts()
                            }
                        } label: {
                            Label(sort.displayName, systemImage: sort.icon)
                                .tag(sort)
                        }
                    }
                } label: {
                    Label(selectedSort.displayName, systemImage: selectedSort.icon)
                        .labelStyle(.iconOnly)
                }
                .tint(.accent)
            }
        }
    }
    
    private func loadInitialPosts() async {
        guard !isLoading && posts.isEmpty else { return }
        
        isLoading = true
        await fetchPosts(isRefresh: true)
        isLoading = false
    }
    
    private func refreshPosts() async {
        await fetchPosts(isRefresh: true)
    }
    
    private func loadMorePosts() {
        guard !isLoading && after != nil else { return }
        
        isLoading = true
        Task {
            await fetchPosts(isRefresh: false)
            isLoading = false
        }
    }
    
    private func fetchPosts(isRefresh: Bool) async {
        let afterParam = isRefresh ? nil : after
        
        let result = await RedditAPI.shared.fetchPosts(subreddit: listingId, sort: selectedSort, after: afterParam, limit: 20)
        
        if let (newPosts, newAfter) = result {
            if isRefresh {
                posts = newPosts
            } else {
                // Filter out duplicates when appending new posts
                let existingIDs = Set(posts.map { $0.id })
                let uniqueNewPosts = newPosts.filter { !existingIDs.contains($0.id) }
                posts.append(contentsOf: uniqueNewPosts)
            }
            after = newAfter
        } else {
            print("Failed to load posts. Check your connection and credentials.")
        }
    }
}

#Preview {
    PostsList(listingId: "")
        
}
