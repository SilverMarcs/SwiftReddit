//
//  PostsList.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI
import Kingfisher

struct PostsList: View {
    @Environment(Nav.self) private var nav
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var after: String?
    @State private var selectedSort: SubListingSortOption = .best
    @State private var showingSubredditInfo = false
    
    let subreddit: Subreddit?
    
    private var listingId: String {
        subreddit?.displayName ?? ""
    }
    
    private var isHomeFeed: Bool {
        subreddit == nil || subreddit?.displayName.isEmpty == true
    }
    
    var body: some View {
        List {
            ForEach(posts) { post in
                Button {
                    nav.path.append(post)
                } label: {
                    PostView(post: post, isHomeFeed: isHomeFeed)
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
        .navigationTitle(isHomeFeed ? "Home" : (subreddit?.displayNamePrefixed ?? ""))
        .toolbarTitleDisplayMode(.inlineLarge)
        .refreshable {
            await refreshPosts()
        }
        .task(id: selectedSort) {
            await loadInitialPosts()
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
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
                .tint(.accent)
                
                if let subreddit = subreddit, !isHomeFeed {
                    Button {
                        showingSubredditInfo = true
                    } label: {
                        if let url = URL(string: subreddit.iconURL ?? "") {
                            KFImage(url)
                                .downsampling(size: CGSize(width: 30, height: 20))
                                .processingQueue(.dispatch(.global()))
                                .fade(duration: 0.1)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "info.circle")
                                .tint(subreddit.color ?? .blue)
                        }
                    }
                    .sheet(isPresented: $showingSubredditInfo) {
                        SubredditInfoView(subreddit: subreddit)
                    }
                }
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
        
        let result = await RedditAPI.shared.fetchPosts(subredditId: listingId, sort: selectedSort, after: afterParam, limit: 20)
        
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
            print("Failed to load posts. Check your connection and credentials.")
        }
    }
}

#Preview {
    PostsList(subreddit: nil)
}
