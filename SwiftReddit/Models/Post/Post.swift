//
//  Post.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import Foundation
import SwiftUI

/// Contains only essential information needed for basic post display
struct Post: Identifiable, Hashable, Equatable {
    let id: String
    let title: String
    let author: String
    let subreddit: Subreddit
    let ups: Int
    let numComments: Int
    let created: Double
    let permalink: String
    let fullname: String
    let isNSFW: Bool
    let isSelf: Bool
    let thumbnail: String?
    let linkFlairText: String?
    let selftext: String
    let downs: Int
    let linkFlairTextColor: String?
    let linkFlairBackgroundColor: String?
    let over18: Bool?
    var saved: Bool
    let likes: Bool? // Vote state: true = upvoted, false = downvoted, nil = no vote
    
    //  media properties
    let mediaType: MediaType
    
    // Custom hash implementation to handle optionals
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    
    init(from postData: PostData) {
        self.id = postData.id
        self.title = postData.title
        self.author = postData.author
        
        self.subreddit = Subreddit(detail: postData.sr_detail!) // TODO: Handle optional safely
        
        self.ups = postData.ups
        self.numComments = postData.num_comments
        self.created = postData.created
        self.permalink = postData.permalink
        self.fullname = postData.name
        self.isNSFW = postData.over_18 ?? false
        self.isSelf = postData.is_self
        self.thumbnail = postData.thumbnail
        self.linkFlairText = postData.link_flair_text
        self.selftext = postData.selftext
        self.downs = postData.downs
        self.linkFlairTextColor = postData.link_flair_text_color
        self.linkFlairBackgroundColor = postData.link_flair_background_color
        self.over18 = postData.over_18
        self.saved = postData.saved
        self.likes = postData.likes
        
        // Extract media information with high-quality image support
        self.mediaType = Post.extractMedia(from: postData)
    }
    
    /// Get flair background color from Reddit API
    var flairBackgroundColor: Color {
        guard let bgColor = linkFlairBackgroundColor, !bgColor.isEmpty else {
            return Color(hex: "D5D7D9") // Default light gray
        }
        return Color(hex: bgColor)
    }
    
    /// Get flair text color from Reddit API
    var flairTextColor: Color {
        let hasBackground = linkFlairBackgroundColor != nil && !linkFlairBackgroundColor!.isEmpty
        
        if hasBackground, let textColor = linkFlairTextColor {
            return textColor == "light" ? .white : .black
        }
        
        return .black // Default
    }
    
    /// Full Reddit URL for sharing
    var redditURL: URL? {
        return URL(string: "https://reddit.com\(permalink)")
    }
}
