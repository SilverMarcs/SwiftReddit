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
    private(set) var after: String?
    
    private let feedType: PostFeedType
    private var selectedSort: SubListingSortOption = .best
    
    init(feedType: PostFeedType) {
        self.feedType = feedType
    }
    
    func updateSort(_ sort: SubListingSortOption) {
        guard feedType.canSort else { return }
        
        if selectedSort != sort {
            selectedSort = sort
            posts = []
            after = nil
        }
    }
    
    func loadInitialPosts() async {
        guard !isLoading && posts.isEmpty else { return }
        
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
        let sortParam = feedType.canSort ? selectedSort : .best
        
        let result = await RedditAPI.shared.fetchPosts(
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
