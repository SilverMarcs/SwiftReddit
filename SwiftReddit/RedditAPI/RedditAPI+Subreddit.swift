//
//  RedditAPI+Subreddit.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import Foundation

extension RedditAPI {
    static func subscribeToSubreddit(_ subredditName: String) async -> Bool {
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/subscribe") else { return false }
        let parameters = "action=sub&sr_name=\(subredditName)&raw_json=1"
        return await performPostRequest(url: url, parameters: parameters)
    }
    
    static func unsubscribeFromSubreddit(_ subredditName: String) async -> Bool {
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/subscribe") else { return false }
        let parameters = "action=unsub&sr_name=\(subredditName)&raw_json=1"
        return await performPostRequest(url: url, parameters: parameters)
    }
}
