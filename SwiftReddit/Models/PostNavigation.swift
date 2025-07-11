//
//  PostNavigation.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import Foundation

struct PostNavigation: Hashable, Codable {
    let postId: String
    let subreddit: String?
    let commentId: String?
    
    init(postId: String, subreddit: String? = nil, commentId: String? = nil) {
        self.postId = postId
        self.subreddit = subreddit
        self.commentId = commentId
    }
    
    init(from post: Post) {
        self.postId = post.id
        self.subreddit = post.subreddit.displayName
        self.commentId = nil
    }
}

extension Message {
    var postNavigation: PostNavigation? {
        // Skip non-navigable message types (like announcements)
        guard type != "unknown", wasComment == true else { return nil }
        
        // Use subreddit field directly from API response
        let subredditName = subreddit
        
        // Extract only the post ID from context since it's not directly available
        guard let context = context else { return nil }
        
        let cleanContext = context.components(separatedBy: "?").first ?? context
        let components = cleanContext.components(separatedBy: "/")
        
        guard components.count >= 5,
              components[1] == "r",
              components[3] == "comments" else { return nil }
        
        let postId = components[4]
        // Use the message ID directly as comment ID (it's the same)
        let commentId = id
        
        return PostNavigation(
            postId: postId,
            subreddit: subredditName,
            commentId: commentId
        )
    }
}
