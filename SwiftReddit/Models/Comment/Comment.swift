//
//  Comment.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import Foundation
import SwiftUI

/// Simplified comment structure for UI display
struct Comment: Identifiable, Hashable, Votable {
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
    let likes: Bool? // Vote state: true = upvoted, false = downvoted, nil = no vote
    // UI state
    var isCollapsed: Bool = false
    
    // Nested structure
    var children: [Comment] = []
    
    /// Get fullname for API calls (t1_ prefix + id)
    var fullname: String {
        return "t1_\(id)"
    }
    
    init(from commentData: CommentData) {
        self.id = commentData.id
        self.author = commentData.author ?? "[deleted]"
        self.body = commentData.body ?? "[deleted]"
        self.created = commentData.created_utc ?? 0
        self.score = commentData.score ?? commentData.ups ?? 0
        self.ups = commentData.ups ?? 0
        self.depth = commentData.depth ?? 0
        self.parentID = commentData.parent_id
        self.isSubmitter = commentData.is_submitter ?? false
        self.authorFlairText = commentData.author_flair_text
        self.authorFlairBackgroundColor = commentData.author_flair_background_color
        self.distinguished = commentData.distinguished
        self.stickied = commentData.stickied ?? false
        self.likes = commentData.likes

        // Process nested replies
        if case .listing(let listing) = commentData.replies {
            self.children = listing.data.children.compactMap { child in
                Comment(from: child.data)
            }
        }
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
    
    /// Flatten comment tree into a list for display
    static func flattenComments(_ comments: [Comment], collapsedIds: Set<String> = []) -> [FlatComment] {
        var result: [FlatComment] = []
        
        func processComment(_ comment: Comment, parentCollapsed: Bool = false) {
            let isCollapsed = collapsedIds.contains(comment.id)
            let isVisible = !parentCollapsed
            
            if isVisible {
                let flatComment = FlatComment(
                    id: comment.id,
                    author: comment.author,
                    body: comment.body,
                    created: comment.created,
                    score: comment.score,
                    ups: comment.ups,
                    depth: comment.depth,
                    parentID: comment.parentID,
                    isSubmitter: comment.isSubmitter,
                    authorFlairText: comment.authorFlairText,
                    authorFlairBackgroundColor: comment.authorFlairBackgroundColor,
                    distinguished: comment.distinguished,
                    stickied: comment.stickied,
                    likes: comment.likes,
                    isVisible: isVisible,
                    hasChildren: comment.hasChildren,
                    isCollapsed: isCollapsed,
                    childCount: comment.totalChildCount
                )
                result.append(flatComment)
            }
            
            // Process children if comment is expanded
            if !isCollapsed {
                for child in comment.children {
                    processComment(child, parentCollapsed: !isVisible)
                }
            }
        }
        
        for comment in comments {
            processComment(comment)
        }
        
        return result
    }
}
