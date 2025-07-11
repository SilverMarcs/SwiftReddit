//
//  FlatComment.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

/// Flattened comment for list display
struct FlatComment: Identifiable, Hashable, Votable {
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
    let likes: Bool?
    
    // Flattened display properties
    let hasChildren: Bool
    let childCount: Int
    let childIds: [String] // Store child IDs for collapse/expand functionality
    
    var fullname: String {
        return "t1_\(id)"
    }
    
    var flairBackgroundColor: Color {
        guard let bgColor = authorFlairBackgroundColor, !bgColor.isEmpty else {
            return Color.clear
        }
        return Color(hex: bgColor)
    }
    
    static func colorForDepth(_ depth: Int) -> Color {
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .red, .pink, .teal, .indigo
        ]
        let index = (depth - 1) % colors.count
        return colors[index]
    }
    
    /// Direct initializer from CommentData for performance optimization
    init(from commentData: CommentData, hasChildren: Bool = false, childCount: Int = 0, childIds: [String] = []) {
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
        self.hasChildren = hasChildren
        self.childCount = childCount
        self.childIds = childIds
    }
    
    // Add this initializer to FlatComment struct
    init(id: String,
         author: String,
         body: String,
         depth: Int,
         parentID: String,
         created: Double = Date().timeIntervalSince1970) {
        self.id = id
        self.author = author
        self.body = body
        self.created = created
        self.depth = depth
        self.parentID = parentID
        
        // Common values for placeholder comments
        self.score = 1
        self.ups = 1
        self.isSubmitter = false
        self.authorFlairText = nil
        self.authorFlairBackgroundColor = nil
        self.distinguished = nil
        self.stickied = false
        self.likes = true
        self.hasChildren = false
        self.childCount = 0
        self.childIds = []
    }
    
    /// Flatten CommentData directly into FlatComment array for optimal performance
    static func flattenCommentData(_ commentDataArray: [CommentData]) -> [FlatComment] {
        var result: [FlatComment] = []
        
        func collectChildIds(from commentData: CommentData) -> [String] {
            guard case .listing(let listing) = commentData.replies else { return [] }
            
            var childIds: [String] = []
            for child in listing.data.children {
                childIds.append(child.data.id)
                childIds.append(contentsOf: collectChildIds(from: child.data))
            }
            return childIds
        }
        
        func processCommentData(_ commentData: CommentData) {
            let childIds = collectChildIds(from: commentData)
            let childCount = childIds.count
            let hasChildren = childCount > 0
            
            let flatComment = FlatComment(
                from: commentData,
                hasChildren: hasChildren,
                childCount: childCount,
                childIds: childIds
            )
            result.append(flatComment)
            
            // Process children recursively
            if case .listing(let listing) = commentData.replies {
                for child in listing.data.children {
                    processCommentData(child.data)
                }
            }
        }
        
        for commentData in commentDataArray {
            processCommentData(commentData)
        }
        
        return result
    }
    
    /// Filter flat comments based on collapsed state for efficient collapse/expand
    static func applyCollapseState(to flatComments: [FlatComment], collapsedIds: Set<String>) -> [FlatComment] {
        var result: [FlatComment] = []
        var hiddenIds: Set<String> = Set()
        
        // Collect all IDs that should be hidden due to collapsed parents
        for collapsedId in collapsedIds {
            if let comment = flatComments.first(where: { $0.id == collapsedId }) {
                hiddenIds.formUnion(comment.childIds)
            }
        }
        
        // Filter out hidden comments
        for comment in flatComments {
            if !hiddenIds.contains(comment.id) {
                result.append(comment)
            }
        }
        
        return result
    }
}
