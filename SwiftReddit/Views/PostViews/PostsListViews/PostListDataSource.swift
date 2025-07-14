//
//  PostListDataSource.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import Foundation

/// Manages data loading for post lists
@Observable class PostListDataSource {
    private(set) var posts: [Post] = []
    private(set) var isLoading = false
    @ObservationIgnored private(set) var after: String?
    var currentSort: SubListingSortOption = .best
    
    @ObservationIgnored private let feedType: PostFeedType
    
    init(feedType: PostFeedType) {
        self.feedType = feedType
    }
    
    func loadInitialPosts() async {
        guard !isLoading else { return }
        
        isLoading = true
        await fetchPosts(isRefresh: true)
        isLoading = false
    }
    
    func loadMorePosts() async {
        guard !isLoading && after != nil else { return }
        
        isLoading = true
        await fetchPosts(isRefresh: false)
        isLoading = false
    }
    
    func refreshPosts() async {
        await fetchPosts(isRefresh: true)
    }
    
    private func fetchPosts(isRefresh: Bool) async {
        let afterParam = isRefresh ? nil : after
        let sortParam = feedType.canSort ? currentSort : .best
        
        let result = await RedditAPI.fetchPosts(
            for: feedType,
            sort: sortParam,
            after: afterParam,
            limit: 20
        )
        
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
