//
//  APISearcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation

extension RedditAPI {
    
    // MARK: - Generic Search Method
    
    private func performSearch<T: Codable>(
        query: String,
        endpoint: String,
        queryItems: [URLQueryItem],
        responseType: T.Type,
        limit: Int = 30
    ) async -> T? {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        var components = URLComponents(string: "\(Self.redditApiURLBase)/\(endpoint)")
        components?.queryItems = queryItems
        
        guard let url = components?.url else { return nil }
        
        guard let request = await createAuthenticatedRequest(url: url) else {
            print("Failed to create authenticated request")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Reddit API Error: Status \(httpResponse.statusCode)")
                return nil
            }
            
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            print("Search error for \(endpoint): \(error)")
            return nil
        }
    }
    
    // MARK: - Subreddit Search
    
    func searchSubreddits(_ query: String, limit: Int = 30) async -> [Subreddit]? {
        let queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "sort", value: "relevance"),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        
        guard let listingResponse: SubredditListing = await performSearch(
            query: query,
            endpoint: "subreddits/search",
            queryItems: queryItems,
            responseType: SubredditListing.self,
            limit: limit
        ) else {
            return query.isEmpty ? [] : nil
        }
        
        return listingResponse.data.children.compactMap { child -> Subreddit? in
            guard child.kind == "t5" else { return nil }
            
            if !Config.shared.allowNSFW && child.data.over18 == true {
                return nil
            }
            return Subreddit(data: child.data)
        }
    }
    
    // MARK: - Post Search
    
    func searchPosts(_ query: String, subreddit: String? = nil, limit: Int = 30) async -> [Post]? {
        let endpoint = subreddit != nil ? "r/\(subreddit!)/search" : "search"
        
        var queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "sort", value: "relevance"),
            URLQueryItem(name: "type", value: "link"),
            URLQueryItem(name: "raw_json", value: "1"),
            URLQueryItem(name: "sr_detail", value: "1")
        ]
        
        if subreddit != nil {
            queryItems.append(URLQueryItem(name: "restrict_sr", value: "true"))
        }
        
        guard let listingResponse: PostListing = await performSearch(
            query: query,
            endpoint: endpoint,
            queryItems: queryItems,
            responseType: PostListing.self,
            limit: limit
        ) else {
            return query.isEmpty ? [] : nil
        }
        
        return listingResponse.data.children.compactMap { child -> Post? in
            guard child.kind == "t3" else { return nil }
            
            if !Config.shared.allowNSFW && child.data.over_18 == true {
                return nil
            }
            return Post(from: child.data)
        }
    }
}
