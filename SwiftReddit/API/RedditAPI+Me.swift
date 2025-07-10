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
    
    // MARK: - Inbox

    func fetchInbox(after: String = "", limit: Int = 25) async -> ([Message]?, String?)? {
        let baseURL = "\(RedditAPI.redditApiURLBase)/message/inbox.json"
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "mark", value: "true"),
            URLQueryItem(name: "count", value: "0"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "show", value: "all"),
            URLQueryItem(name: "sr_detail", value: "1"),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        
        if !after.isEmpty {
            components?.queryItems?.append(URLQueryItem(name: "after", value: after))
        }
        
        guard let url = components?.url else { return nil }
        
        if let listing = await performAuthenticatedRequest(url: url, responseType: MessageListing.self) {
            let messages = listing.data.children.map { $0.data }
            return (messages, listing.data.after)
        }
        
        return nil
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
