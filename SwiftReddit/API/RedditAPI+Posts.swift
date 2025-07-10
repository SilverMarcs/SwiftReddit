//
//  APIPostFetcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation
import Kingfisher

extension RedditAPI {
    func fetchPosts(for feedType: PostFeedType, sort: SubListingSortOption = .best, after: String? = nil, limit: Int = 10) async -> ([Post], String?)? {
        guard let url = buildPostsURL(for: feedType, sort: sort, after: after, limit: limit) else { return nil }
        return await fetchPostsFromURL(url: url)
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
            let subredditPath = "r/\(subreddit.displayName)"
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
        
        // Prefetch images for all posts
//        MyImagePrefetcher.prefetchImagesForPosts(posts)
        
        return (posts, listingResponse.data.after)
    }
    
    // MARK: - Post Actions
    
    /// Vote on a post (upvote, downvote, or remove vote)
    /// - Parameters:
    ///   - action: The vote action to perform
    ///   - id: The fullname of the post (e.g., t3_postid)
    /// - Returns: true if successful, false otherwise
    @discardableResult
    func vote(_ action: VoteAction, id: String) async -> Bool? {
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/vote") else {
            return nil
        }
        
        guard var request = await createAuthenticatedRequest(url: url, method: "POST") else {
            return nil
        }
        
        let parameters = "dir=\(action.rawValue)&id=\(id)&api_type=json&raw_json=1"
        request.httpBody = parameters.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            AppLogger.critical("Vote error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Save or unsave a post
    /// - Parameters:
    ///   - save: true to save, false to unsave
    ///   - id: The fullname of the post (e.g., t3_postid)
    /// - Returns: true if successful, false otherwise
    func save(_ save: Bool, id: String) async -> Bool? {
        let endpoint = save ? "save" : "unsave"
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/\(endpoint)") else {
            return nil
        }
        
        guard var request = await createAuthenticatedRequest(url: url, method: "POST") else {
            return nil
        }
        
        let parameters = "id=\(id)"
        request.httpBody = parameters.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            AppLogger.critical("Save/unsave error: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Vote Action Enum

extension RedditAPI {
    enum VoteAction: String, Codable {
        case up = "1"
        case none = "0"
        case down = "-1"
        
        func boolVersion() -> Bool? {
            switch self {
            case .up:
                return true
            case .none:
                return nil
            case .down:
                return false
            }
        }
    }
}
