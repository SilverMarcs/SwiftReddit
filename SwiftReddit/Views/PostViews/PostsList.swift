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
    @State private var showingSubredditInfo = false
    
    @State private var selectedSort: SubListingSortOption = .best {
        didSet {
            if selectedSort != oldValue {
                posts = []
                after = nil
            }
        }
    }
    
    let feedType: PostFeedType
    
    var body: some View {
        List {
            ForEach(posts) { post in
                Button {
                    nav.path.append(post)
                } label: {
                    PostView(post: post)
                        .navigationLinkIndicatorVisibility(.hidden)
                    #if !os(macOS)
                        .contentShape(.contextMenuPreview, .rect(cornerRadius: 16))
                    #endif
                }
                .buttonStyle(.plain)
                .listRowInsets(.vertical, 5)
                .listRowInsets(.horizontal, 6)
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
        .navigationTitle(feedType.displayName)
//        .navigationSubtitle(feedType.subreddit?.subscriberCount.formatted() ?? "")
        .toolbarTitleDisplayMode(.inlineLarge)
        .refreshable {
            await refreshPosts()
        }
        .task(id: selectedSort) {
            await loadInitialPosts()
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if feedType.canSort {
                    Menu {
                        // Standard sorting options
                        ForEach(SubListingSortOption.allCases, id: \.id) { sort in
                            Button {
                                selectedSort = sort
                            } label: {
                                Label(sort.displayName, systemImage: sort.icon)
                            }
                        }
                        
                        // Top submenu with time periods
                        Menu {
                            ForEach(SubListingSortOption.topOptions, id: \.id) { topOption in
                                Button {
                                    selectedSort = topOption
                                } label: {
                                    Label(topOption.displayName, systemImage: topOption.icon)
                                }
                            }
                        } label: {
                            Label("Top", systemImage: "arrow.up.circle")
                        }
                    } label: {
                        Label(selectedSort.displayName, systemImage: selectedSort.icon)
                            .labelStyle(.iconOnly)
                    }
                    .tint(.accent)
                }
                
                if feedType.showSubredditInfo, let subreddit = feedType.subreddit {
                    Button {
                        showingSubredditInfo = true
                    } label: {
                        if let url = URL(string: subreddit.iconURL ?? "") {
                            KFImage(url)
                                .downsampling(size: CGSize(width: 30, height: 20))
//                                .processingQueue(.dispatch(.global()))
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
        let sortParam = feedType.canSort ? selectedSort : .best
        
        let result = await RedditAPI.shared.fetchPosts(for: feedType, sort: sortParam, after: afterParam, limit: 20)
        
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
    PostsList(feedType: .home)
}
