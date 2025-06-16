//
//  PostsView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct PostsView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var after: String?
    @State private var selectedSort: SubListingSortOption = .best
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(posts) { post in
                    PostView(post: post)
                        .listRowInsets(.vertical, 5)
                        .listRowInsets(.horizontal, 5)
                }
                .listRowSeparator(.hidden)
                
                Color.clear
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
                        .frame(maxWidth: .infinity)
                        .padding()
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Sort", selection: $selectedSort) {
                        ForEach(SubListingSortOption.allCases) { sort in
                            Label(sort.displayName, systemImage: sort.icon)
                                .labelStyle(.iconOnly)
                                .tag(sort)
                        }
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
        
        Task {
            isLoading = true
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
                posts.append(contentsOf: newPosts)
            }
            after = newAfter
        } else {
            print("Failed to load posts. Check your connection and credentials.")
        }
    }
}

#Preview {
    PostsView()
}
