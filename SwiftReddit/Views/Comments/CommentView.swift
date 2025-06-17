//
//  CommentView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct CommentView: View {
    @State var comment: Comment
    let onToggleCollapse: (Comment) -> Void
    
    private let maxDepth = 8 // Limit visual depth to prevent excessive indentation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Comment content
            commentContent
            
            // Children comments (if not collapsed)
            if !comment.isCollapsed && comment.hasChildren {
                ForEach(comment.children, id: \.id) { child in
                    CommentView(comment: child, onToggleCollapse: onToggleCollapse)
                }
            }
        }
    }
    
    private var commentContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Comment header
            commentHeader
            
            // Comment body (if not collapsed)
            if !comment.isCollapsed {
                commentBody
            } else if comment.hasChildren {
                collapsedIndicator
            }
        }
        .padding(.leading, comment.depth < maxDepth ? comment.indentationWidth : CGFloat(maxDepth * 12))
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.systemBackground))
        .onTapGesture {
            if comment.hasChildren {
                withAnimation(.easeInOut(duration: 0.2)) {
                    comment = comment.toggleCollapsed()
                    onToggleCollapse(comment)
                }
            }
        }
    }
    
    private var commentHeader: some View {
        HStack(spacing: 8) {
            // Author with flair
            HStack(spacing: 4) {
                Text(comment.author)
                    .font(.caption)
                    .fontWeight(comment.isSubmitter ? .bold : .medium)
                    .foregroundColor(comment.isSubmitter ? .blue : .primary)
                
                if let flairText = comment.authorFlairText, !flairText.isEmpty {
                    Text(flairText)
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(comment.flairBackgroundColor.opacity(0.2))
                        .foregroundColor(.secondary)
                        .cornerRadius(4)
                }
                
                if comment.distinguished == "moderator" {
                    Text("MOD")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.green)
                        .cornerRadius(4)
                }
                
                if comment.stickied {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Score and time
            HStack(spacing: 8) {
                if comment.score > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up")
                            .font(.caption2)
                        Text(comment.formattedScore)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Text(comment.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if comment.hasChildren {
                    Image(systemName: comment.isCollapsed ? "plus" : "minus")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var commentBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Comment text
            Text(comment.body.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            // Comment actions
            if !comment.archived {
                commentActions
            }
        }
    }
    
    private var commentActions: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                    Text("Vote")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.left")
                    Text("Reply")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: comment.saved ? "bookmark.fill" : "bookmark")
                    Text(comment.saved ? "Saved" : "Save")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.top, 4)
    }
    
    private var collapsedIndicator: some View {
        Text("[\(comment.totalChildCount) \(comment.totalChildCount == 1 ? "reply" : "replies")]")
            .font(.caption)
            .foregroundColor(.secondary)
            .italic()
    }
}
