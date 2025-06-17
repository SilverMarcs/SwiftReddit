//
//  Comment.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import Foundation
import SwiftUI

/// Simplified comment structure for UI display
struct Comment: Identifiable, Hashable {
    let id: String
    let author: String
    let body: String
    let bodyHTML: String
    let created: Double
    let score: Int
    let ups: Int
    let depth: Int
    let permalink: String
    let parentID: String?
    let subreddit: String
    let fullname: String
    let isSubmitter: Bool
    let authorFlairText: String?
    let authorFlairBackgroundColor: String?
    let saved: Bool
    let archived: Bool
    let distinguished: String?
    let stickied: Bool
    let gilded: Int
    let totalAwardsReceived: Int
    let locked: Bool
    
    // UI state
    var isCollapsed: Bool = false
    
    // Nested structure
    var children: [Comment] = []
    
    init(from commentData: CommentData) {
        self.id = commentData.id
        self.author = commentData.author
        self.body = commentData.body
        self.bodyHTML = commentData.body_html
        self.created = commentData.created_utc
        self.score = commentData.score ?? commentData.ups ?? 0
        self.ups = commentData.ups ?? 0
        self.depth = commentData.depth ?? 0
        self.permalink = commentData.permalink ?? ""
        self.parentID = commentData.parent_id
        self.subreddit = commentData.subreddit ?? ""
        self.fullname = commentData.name
        self.isSubmitter = commentData.is_submitter ?? false
        self.authorFlairText = commentData.author_flair_text
        self.authorFlairBackgroundColor = commentData.author_flair_background_color
        self.saved = commentData.saved
        self.archived = commentData.archived
        self.distinguished = commentData.distinguished
        self.stickied = commentData.stickied ?? false
        self.gilded = commentData.gilded ?? 0
        self.totalAwardsReceived = commentData.total_awards_received ?? 0
        self.locked = commentData.locked ?? false
        
        // Process nested replies
        if case .listing(let listing) = commentData.replies {
            self.children = listing.data.children.compactMap { child in
                Comment(from: child.data)
            }
        }
    }
    
    /// Format time for display
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
    
    /// Format score for display
    var formattedScore: String {
        if score >= 1000 {
            return String(format: "%.1fk", Double(score) / 1000.0)
        }
        return String(score)
    }
    
    /// Get author flair background color
    var flairBackgroundColor: Color {
        guard let bgColor = authorFlairBackgroundColor, !bgColor.isEmpty else {
            return Color.clear
        }
        return Color(hex: bgColor)
    }
    
    /// Get comment depth indentation
    var indentationWidth: CGFloat {
        return CGFloat(depth * 12)
    }
    
    /// Check if comment has children
    var hasChildren: Bool {
        return !children.isEmpty
    }
    
    /// Get total child count (recursive)
    var totalChildCount: Int {
        return children.reduce(children.count) { $0 + $1.totalChildCount }
    }
    
    /// Toggle collapsed state and return new instance
    func toggleCollapsed() -> Comment {
        var newComment = self
        newComment.isCollapsed.toggle()
        return newComment
    }
}

/// Comment sort options
enum CommentSortOption: String, CaseIterable {
    case confidence = "confidence"
    case top = "top"
    case new = "new"
    case controversial = "controversial"
    case old = "old"
    case random = "random"
    case qa = "qa"
    case live = "live"
    
    var displayName: String {
        switch self {
        case .confidence: return "Best"
        case .top: return "Top"
        case .new: return "New"
        case .controversial: return "Controversial"
        case .old: return "Old"
        case .random: return "Random"
        case .qa: return "Q&A"
        case .live: return "Live"
        }
    }
    
    var iconName: String {
        switch self {
        case .confidence: return "flame"
        case .top: return "trophy"
        case .new: return "newspaper"
        case .controversial: return "figure.fencing"
        case .old: return "clock.arrow.circlepath"
        case .random: return "dice"
        case .qa: return "bubble.left.and.bubble.right"
        case .live: return "dot.radiowaves.left.and.right"
        }
    }
}
