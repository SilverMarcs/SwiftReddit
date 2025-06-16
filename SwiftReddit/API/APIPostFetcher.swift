//
//  APIPostFetcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

extension RedditAPI {
    func fetchHomeFeed(sort: SubListingSortOption = .best, after: String? = nil, limit: Int = 10) async -> ([Post], String?)? {
        return await fetchPosts(endpoint: "", sort: sort, after: after, limit: limit)
    }
    
    func fetchSubredditPosts(subreddit: String, sort: SubListingSortOption = .best, after: String? = nil, limit: Int = 10) async -> ([Post], String?)? {
        let endpoint = subreddit.isEmpty ? "" : "r/\(subreddit)"
        return await fetchPosts(endpoint: endpoint, sort: sort, after: after, limit: limit)
    }
    
    private func fetchPosts(endpoint: String, sort: SubListingSortOption, after: String?, limit: Int) async -> ([Post], String?)? {
        guard let accessToken = await CredentialsManager.shared.getValidAccessToken() else {
            print("No valid credential or access token")
            return nil
        }
        
        var urlString = "\(Self.redditApiURLBase)/\(endpoint)"
        if !endpoint.isEmpty {
            urlString += "/"
        }
        urlString += sort.rawValue.lowercased()
        
        var components = URLComponents(string: urlString)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        
        if let after = after {
            components?.queryItems?.append(URLQueryItem(name: "after", value: after))
        }
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let userName = CredentialsManager.shared.credential?.userName ?? "UnknownUser"
        request.setValue("ios:lo.cafe.winston:v0.1.0 (by /u/\(userName))", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
//                print("Reddit API Response Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("Reddit API Error: Status \(httpResponse.statusCode)")
                    return nil
                }
            }
            
            let listingResponse = try JSONDecoder().decode(ListingResponse.self, from: data)
            let posts = listingResponse.data.children.compactMap { child -> Post? in
                guard child.kind == "t3" else { return nil }
                return Post(from: child.data)
            }
            
            return (posts, listingResponse.data.after)
        } catch {
            print("Fetch posts error: \(error)")
            return nil
        }
    }
}
