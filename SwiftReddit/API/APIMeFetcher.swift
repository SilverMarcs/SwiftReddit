//
//  APIMeFetcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

extension RedditAPI {
    func fetchMe() async -> UserData? {
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/v1/me") else { return nil }
        return await performAuthenticatedRequest(url: url, responseType: UserData.self)
    }
    
    // Legacy method for backward compatibility
    func fetchMe(with accessToken: String, userAgent: String) async -> UserData? {
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/v1/me") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(UserData.self, from: data)
        } catch {
            print("Fetch me error: \(error)")
            return nil
        }
    }
    
    // MARK: - Subreddits List
    
    func fetchUserSubreddits() async -> [Subreddit]? {
        guard let url = URL(string: "\(RedditAPI.redditApiURLBase)/subreddits/mine/subscriber.json?limit=100") else {
            return nil
        }
        
        guard let response: Listing<SubredditData> = await performAuthenticatedRequest(url: url, responseType: Listing<SubredditData>.self) else {
            return nil
        }
        
        return response.data.children.compactMap { child in
            return Subreddit(data: child.data)
        }
    }
}
