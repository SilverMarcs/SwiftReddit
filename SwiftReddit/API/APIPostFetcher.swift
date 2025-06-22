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
        guard let accessToken = await CredentialsManager.shared.getValidAccessToken() else {
            print("No valid credential or access token")
            return nil
        }
        
        let request = createAuthenticatedRequest(url: url, accessToken: accessToken)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Reddit API Error: Status \(httpResponse.statusCode)")
                return nil
            }
            
            let listingResponse = try JSONDecoder().decode(PostListingResponse.self, from: data)
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
