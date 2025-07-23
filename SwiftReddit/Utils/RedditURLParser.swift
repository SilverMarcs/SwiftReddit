//
//  RedditURLParser.swift
//  SwiftReddit
//
//  Created by Copilot on 23/07/2025.
//

import Foundation

struct RedditURLParser {
    static func parsePostNavigation(from url: URL) -> PostNavigation? {
        // Accept both reddit.com and app.link URLs
        let path: String
        if let deeplinkPath = url.queryItems?["$deeplink_path"] ?? url.queryItems?["base_url"] {
            path = deeplinkPath
        } else {
            path = url.path
        }
        // Match /r/{subreddit}/comments/{postId}/
        let regex = try! NSRegularExpression(pattern: #"/r/([\w_]+)/comments/([\w]+)/?"#, options: .caseInsensitive)
        let nsPath = path as NSString
        if let match = regex.firstMatch(in: path, options: [], range: NSRange(location: 0, length: nsPath.length)),
           match.numberOfRanges >= 3 {
            let subreddit = nsPath.substring(with: match.range(at: 1))
            let postId = nsPath.substring(with: match.range(at: 2))
            return PostNavigation(postId: postId, subreddit: subreddit)
        }
        return nil
    }
}

private extension URL {
    var queryItems: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let items = components.queryItems else { return nil }
        return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
    }
}
