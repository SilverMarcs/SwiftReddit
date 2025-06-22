//
//  APIPostFetcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

extension RedditAPI {
    func fetchPosts(subredditId: String, sort: SubListingSortOption = .best, after: String? = nil, limit: Int = 10) async -> ([Post], String?)? {
        guard let url = buildPostsURL(subredditId: subredditId, sort: sort, after: after, limit: limit) else { return nil }
        return await fetchPostsFromURL(url: url)
    }
    
    // MARK: - Private Helper Methods
    
    private func buildPostsURL(subredditId: String, sort: SubListingSortOption, after: String?, limit: Int) -> URL? {
        let endpoint = subredditId.isEmpty ? "" : subredditId.withSubredditPrefix
        var urlString = "\(Self.redditApiURLBase)/\(endpoint)"
        if !endpoint.isEmpty {
            urlString += "/"
        }
        urlString += sort.rawValue.lowercased()
        
        var components = URLComponents(string: urlString)
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
    
    private func fetchPostsFromURL(url: URL) async -> ([Post], String?)? {
        guard let listingResponse = await performAuthenticatedRequest(url: url, responseType: PostListingResponse.self) else {
            return nil
        }
        
        let posts = listingResponse.data.children.compactMap { child -> Post? in
            guard child.kind == "t3" else { return nil }
            return Post(from: child.data)
        }
        
        return (posts, listingResponse.data.after)
    }
}
