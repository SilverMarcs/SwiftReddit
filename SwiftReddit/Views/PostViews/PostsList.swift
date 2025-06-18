//
//  PostsList.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI
import WebKit

struct PostsList: View {
    @ObservedObject private var appPrefs = AppPreferences.shared
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var after: String?
    @State private var selectedSort: SubListingSortOption = .best
    @State private var navigationPath = NavigationPath()
    @State private var showImagePreview = false
    @State private var imagePreviewURL: String?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
            .listStyle(.plain)
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inlineLarge)
            .refreshable {
                await refreshPosts()
            }
            .task {
                guard !appPrefs.hasLaunched else { return }
                await loadInitialPosts()
                appPrefs.hasLaunched = true
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
            .navigationDestination(for: Post.self) { post in
                PostDetail(post: post)
            }
            .navigationDestination(for: LinkMetadata.self) { meta in
                BasicWebview(linkMeta: meta)
            }
            .sheet(isPresented: $showImagePreview) {
                if let imageURL = imagePreviewURL {
                    NavigationStack {
                        ZoomableImageModal(imageURL: imageURL)
                            .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                    Button {
                                        showImagePreview = false
                                    } label: {
                                        Image(systemName: "xmark")
                                    }
                                }
                            }
                    }
                }
            }
        }
        .environment(\.openURL, OpenURLAction { url in
            // Check if it's a Reddit preview image URL
            if isRedditImagePreviewURL(url) {
                imagePreviewURL = url.absoluteString
                showImagePreview = true
                return .handled
            }
            
            let linkMetadata = LinkMetadata(
                url: url.absoluteString,
                domain: url.host ?? "Unknown",
                thumbnailURL: nil
            )
            
            navigationPath.append(linkMetadata)
            
            return .handled
        })
    }
    
    private func isRedditImagePreviewURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString.lowercased()
        
        // Check for Reddit preview URLs (preview.redd.it, i.redd.it)
        if urlString.contains("preview.redd.it") || urlString.contains("i.redd.it") {
            return true
        }
        
        // Check for common image extensions
        let imageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".webp"]
        return imageExtensions.contains { urlString.hasSuffix($0) }
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
        
        let result = await RedditAPI.shared.fetchHomeFeed(sort: selectedSort, after: afterParam, limit: 20)
        
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
