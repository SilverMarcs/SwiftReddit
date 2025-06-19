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
    let created: Double
    let score: Int
    let ups: Int
    let depth: Int
    let parentID: String?
    let isSubmitter: Bool
    let authorFlairText: String?
    let authorFlairBackgroundColor: String?
    let distinguished: String?
    let stickied: Bool
    // UI state
    var isCollapsed: Bool = false
    
    // Nested structure
    var children: [Comment] = []
    
    init(from commentData: CommentData) {
        self.id = commentData.id
        self.author = commentData.author
        self.body = commentData.body
        self.created = commentData.created_utc
        self.score = commentData.score ?? commentData.ups ?? 0
        self.ups = commentData.ups ?? 0
        self.depth = commentData.depth ?? 0
        self.parentID = commentData.parent_id
        self.isSubmitter = commentData.is_submitter ?? false
        self.authorFlairText = commentData.author_flair_text
        self.authorFlairBackgroundColor = commentData.author_flair_background_color
        self.distinguished = commentData.distinguished
        self.stickied = commentData.stickied ?? false

        // Process nested replies
        if case .listing(let listing) = commentData.replies {
            self.children = listing.data.children.compactMap { child in
                Comment(from: child.data)
            }
        }
    }
    
    /// Format time for display
    var timeAgo: String {
        return created.timeAgo
    }
    
    /// Format score for display
    var formattedScore: String {
        return score.formatted
    }
    
    /// Get author flair background color
    var flairBackgroundColor: Color {
        guard let bgColor = authorFlairBackgroundColor, !bgColor.isEmpty else {
            return Color.clear
        }
        return Color(hex: bgColor)
    }
    
    /// Check if comment has children
    var hasChildren: Bool {
        return !children.isEmpty
    }
    
    /// Get total child count (recursive)
    var totalChildCount: Int {
        return children.reduce(children.count) { $0 + $1.totalChildCount }
    }
    
    /// Set collapsed state and return new instance
    func withCollapsedState(_ collapsed: Bool) -> Comment {
        var newComment = self
        newComment.isCollapsed = collapsed
        return newComment
    }
}
