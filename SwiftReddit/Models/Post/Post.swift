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
        
        // Extract media information with high-quality image support
        self.mediaType = Post.extractMedia(from: postData)
    }
    
    /// Basic relative time string for display
    var timeAgo: String {
        let timeInterval = Date().timeIntervalSince1970 - created
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
    
    /// Format vote count for display
    var formattedUps: String {
        if ups >= 1000 {
            return String(format: "%.1fk", Double(ups) / 1000.0)
        }
        return String(ups)
    }
    
    /// Format comment count for display
    var formattedComments: String {
        if numComments >= 1000 {
            return String(format: "%.1fk", Double(numComments) / 1000.0)
        }
        return String(numComments)
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
}
