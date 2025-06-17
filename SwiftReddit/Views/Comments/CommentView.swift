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
    let isTopLevel: Bool
    
    private let maxDepth = 8 // Limit visual depth to prevent excessive indentation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Comment content
            commentContent
            
            // Children comments (if not collapsed)
            if !comment.isCollapsed && comment.hasChildren {
                ForEach(comment.children, id: \.id) { child in
                    CommentView(comment: child, onToggleCollapse: onToggleCollapse, isTopLevel: false)
                }
            }
        }
        .opacity(comment.isCollapsed ? 0.5 : 1.0)
        .contentShape(.rect)
        .background(isTopLevel ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 12))
        .onTapGesture {
            if comment.hasChildren {
                withAnimation(.easeInOut(duration: 0.2)) {
                    comment = comment.toggleCollapsed()
                    onToggleCollapse(comment)
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
    }
    
    private var commentHeader: some View {
        HStack {
            // Avatar logo or subreddit logo TODO:
            Image(systemName: "person.crop.circle.fill")
                .font(.title)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if comment.stickied {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    
                    Text(comment.author)
                        .font(.caption)
                        .fontWeight(comment.isSubmitter ? .bold : .medium)
                        .foregroundStyle(comment.isSubmitter ? .blue : .secondary)
                    
                    if let flairText = comment.authorFlairText, !flairText.isEmpty {
                        Text(flairText)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(comment.flairBackgroundColor.opacity(0.2))
                            .foregroundStyle(.secondary)
                            .cornerRadius(4)
                    }
                    
                    if comment.distinguished == "moderator" {
                        Text("MOD")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    
                    Text(comment.timeAgo)
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(alignment: .center) {
                Image(systemName: "arrow.up")
                    .font(.subheadline)
                
                Text(comment.formattedScore)
                    .font(.subheadline)
                
                Image(systemName: "arrow.down")
                    .font(.subheadline)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(.background.tertiary, in: .rect(cornerRadius: 14))
            .foregroundStyle(.secondary)
            .fontWeight(.semibold)
        }
    }
    
    private var commentBody: some View {
        Text(LocalizedStringKey(comment.body.trimmingCharacters(in: .whitespacesAndNewlines)))
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var collapsedIndicator: some View {
        Text("[\(comment.totalChildCount) \(comment.totalChildCount == 1 ? "reply" : "replies")]")
            .font(.caption)
            .foregroundStyle(.secondary)
            .italic()
    }
}
