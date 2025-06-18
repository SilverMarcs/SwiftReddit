//
//  APISubredditSearcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation

extension RedditAPI {
    func searchSubreddits(_ query: String, limit: Int = 25) async -> [SubredditData]? {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        guard let accessToken = await CredentialsManager.shared.getValidAccessToken() else {
            print("No valid credential or access token")
            return nil
        }
        
        var components = URLComponents(string: "\(Self.redditApiURLBase)/subreddits/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "show", value: "all"),
            URLQueryItem(name: "sr_detail", value: "1"),
            URLQueryItem(name: "sort", value: "relevance"),
            URLQueryItem(name: "raw_json", value: "1"),
            URLQueryItem(name: "typeahead_active", value: "true")
        ]
        
        guard let url = components?.url else {
            print("Failed to construct search URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let userName = CredentialsManager.shared.credential?.userName ?? "UnknownUser"
        request.setValue("ios:lo.cafe.winston:v0.1.0 (by /u/\(userName))", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("Reddit API Error: Status \(httpResponse.statusCode)")
                    return nil
                }
            }
            
            let listingResponse = try JSONDecoder().decode(SubredditListingResponse.self, from: data)
            let subreddits = listingResponse.data.children.compactMap { child -> SubredditData? in
                guard child.kind == "t5" else { return nil }
                return child.data
            }
            
            return subreddits
        } catch {
            print("Search subreddits error: \(error)")
            return nil
        }
    }
}

// MARK: - Response Models
struct SubredditListingResponse: Codable {
    let kind: String
    let data: SubredditListingData
}

struct SubredditListingData: Codable {
    let modhash: String?
    let dist: Int?
    let children: [SubredditChild]
    let after: String?
    let before: String?
}

struct SubredditChild: Codable {
    let kind: String
    let data: SubredditData
}
