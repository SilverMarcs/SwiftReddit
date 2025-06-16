//
//  PostsList.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct PostsList: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var after: String?
    @State private var selectedSort: SubListingSortOption = .best
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(posts) { post in
                    NavigationLink(value: post) {
                        PostView(post: post)
                    }
                    .listRowInsets(.vertical, 5)
                    .listRowInsets(.horizontal, 5)
                    .navigationLinkIndicatorVisibility(.hidden)
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
            .navigationDestination(for: Post.self) { post in
                PostDetail(post: post)
            }
            .listStyle(.plain)
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(SubListingSortOption.allCases) { sort in
                            Button {
                                selectedSort = sort
                            } label: {
                                Label(sort.displayName, systemImage: sort.icon)
                                    .tag(sort)
                            }
                        }
                    } label: {
                        Label(selectedSort.displayName, systemImage: selectedSort.icon)
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .refreshable {
                await refreshPosts()
            }
            .task(id: posts.isEmpty) {
                await loadInitialPosts()
            }
            .task(id: selectedSort) {
                await refreshPosts()
            }
        }
    }
    
    private func loadInitialPosts() async {
        guard !isLoading else { return }
        
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
        
        let result = await RedditAPI.shared.fetchHomeFeed(sort: selectedSort, after: afterParam, limit: 10)
        
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
    PostsList()
}
