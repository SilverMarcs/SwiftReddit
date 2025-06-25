//
//  APIPostFetcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

extension RedditAPI {
    func fetchPosts(for feedType: PostFeedType, sort: SubListingSortOption = .best, after: String? = nil, limit: Int = 10) async -> ([Post], String?)? {
        guard let url = buildPostsURL(for: feedType, sort: sort, after: after, limit: limit) else { return nil }
        return await fetchPostsFromURL(url: url)
    }
    
    // Legacy method for backward compatibility
    func fetchPosts(subredditId: String, sort: SubListingSortOption = .best, after: String? = nil, limit: Int = 10) async -> ([Post], String?)? {
        let feedType: PostFeedType = subredditId.isEmpty ? .home : .subreddit(Subreddit(displayName: subredditId))
        return await fetchPosts(for: feedType, sort: sort, after: after, limit: limit)
    }
    
    // MARK: - Private Helper Methods
    
    private func buildPostsURL(for feedType: PostFeedType, sort: SubListingSortOption, after: String?, limit: Int) -> URL? {
        guard let endpoint = buildEndpoint(for: feedType, sort: sort) else { return nil }
        
        var components = URLComponents(string: "\(Self.redditApiURLBase)\(endpoint)")
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "raw_json", value: "1"),
            URLQueryItem(name: "sr_detail", value: "1")
        ]
        
        if let after = after {
            components?.queryItems?.append(URLQueryItem(name: "after", value: after))
        }
        
        return components?.url
    }
    
    private func buildEndpoint(for feedType: PostFeedType, sort: SubListingSortOption) -> String? {
        let sortPath = sort.rawValue.lowercased()
        
        switch feedType {
        case .home:
            return "/\(sortPath)"
            
        case .subreddit(let subreddit):
            let subredditPath = subreddit.displayName.withSubredditPrefix
            return "/\(subredditPath)/\(sortPath)"
            
        case .saved:
            guard let username = CredentialsManager.shared.credential?.userName else {
                AppLogger.error("No username available for saved posts")
                return nil
            }
            return "/user/\(username)/saved"
            
        case .user(let username):
            return "/user/\(username)/submitted"
        }
    }
    
    private func fetchPostsFromURL(url: URL) async -> ([Post], String?)? {
        guard let listingResponse = await performAuthenticatedRequest(url: url, responseType: PostListingResponse.self) else {
            return nil
        }
        
        let posts = listingResponse.data.children.compactMap { child -> Post? in
            guard child.kind == "t3" else { return nil }
            // Filter out NSFW posts based on config setting
            if !Config.shared.allowNSFW && child.data.over_18 == true {
                return nil
            }
            return Post(from: child.data)
        }
        
        return (posts, listingResponse.data.after)
    }
}
