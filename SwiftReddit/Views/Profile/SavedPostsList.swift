//
//  SavedPostsList.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 22/06/2025.
//

import SwiftUI

struct SavedPostsList: View {
    @Environment(Nav.self) private var nav
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var after: String?
    
    var body: some View {
        List {
            ForEach(posts) { post in
                Button {
                    nav.path.append(post)
                } label: {
                    PostView(post: post, isHomeFeed: false)
                        .navigationLinkIndicatorVisibility(.hidden)
                }
                .buttonStyle(.plain)
                .listRowInsets(.vertical, 5)
                .listRowInsets(.horizontal, 5)
            }
            .listRowSeparator(.hidden)
            
            Color.clear
                .frame(height: 1)
                .onAppear {
                    if !isLoading && after != nil {
                        loadMorePosts()
                    }
                }
                .listRowSeparator(.hidden)
            
            if isLoading {
                ProgressView()
                    .id(UUID())
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Saved Posts")
        .toolbarTitleDisplayMode(.inlineLarge)
        .refreshable {
            await refreshPosts()
        }
        .task {
            await loadInitialPosts()
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
        
        let result = await RedditAPI.shared.fetchSavedPosts(after: afterParam, limit: 20)
        
        if let (newPosts, newAfter) = result {
            if isRefresh {
                posts = newPosts
            } else {
                let existingIDs = Set(posts.map { $0.id })
                let uniqueNewPosts = newPosts.filter { !existingIDs.contains($0.id) }
                posts.append(contentsOf: uniqueNewPosts)
            }
            after = newAfter
        } else {
            print("Failed to load saved posts. Check your connection and credentials.")
        }
    }
}

#Preview {
    SavedPostsList()
}
