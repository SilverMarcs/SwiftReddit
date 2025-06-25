//
//  APISubredditSearcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation

extension RedditAPI {
    func searchSubreddits(_ query: String, limit: Int = 30) async -> [Subreddit]? {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        guard let url = buildSubredditSearchURL(query: query, limit: limit) else {
            print("Failed to construct search URL")
            return nil
        }
        
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
            
            let listingResponse = try JSONDecoder().decode(SubredditListing.self, from: data)
            let subreddits = listingResponse.data.children.compactMap { child -> Subreddit? in
                guard child.kind == "t5" else { return nil }
                
                if !Config.shared.allowNSFW && child.data.over18 == true {
                    return nil
                }
                return Subreddit(data: child.data)
            }
            
            return subreddits
        } catch {
            print("Search subreddits error: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func buildSubredditSearchURL(query: String, limit: Int) -> URL? {
        var components = URLComponents(string: "\(Self.redditApiURLBase)/subreddits/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "show", value: "all"),
            URLQueryItem(name: "sr_detail", value: "1"),
            URLQueryItem(name: "sort", value: "relevance"),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        
        return components?.url
    }
}


