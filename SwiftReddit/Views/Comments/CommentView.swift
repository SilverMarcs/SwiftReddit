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
    @State private var isExpanded: Bool
    
    private let maxDepth = 8 // Limit visual depth to prevent excessive indentation
    
    init(comment: Comment, onToggleCollapse: @escaping (Comment) -> Void, isTopLevel: Bool) {
        self.comment = comment
        self.onToggleCollapse = onToggleCollapse
        self.isTopLevel = isTopLevel
        self._isExpanded = State(initialValue: !comment.isCollapsed)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if comment.hasChildren {
                DisclosureGroup(isExpanded: $isExpanded) {
                    // Children comments
                    ForEach(comment.children, id: \.id) { child in
                        CommentView(comment: child, onToggleCollapse: onToggleCollapse, isTopLevel: false)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        commentContent
                        // Divider after the comment content, before children
                        if isExpanded {   
                            commentDivider
                        }
                    }
                }
                .disclosureGroupStyle(CommentDisclosureStyle())
                .onChange(of: isExpanded) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        comment = comment.withCollapsedState(!newValue)
                        onToggleCollapse(comment)
                    }
                }
            } else {
                // Comment without children - just show content
                commentContent
            }
        }
        .background(isTopLevel ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 14))
    }
    
    private var commentContent: some View {
        HStack(alignment: .top, spacing: 0) {
            // Colored rectangle for depth indication (only for non-top-level comments)
            if !isTopLevel && comment.depth > 0 {
                // Add spacing for parent depths
                if comment.depth > 1 {
                    Spacer()
                        .frame(width: CGFloat((comment.depth - 1) * 12))
                }
                
                // Show only this comment's own depth rectangle
                Rectangle()
                    .fill(colorForDepth(comment.depth))
                    .frame(width: 2)
                    .padding(.trailing, 9) // 12 - 2 = 9 to maintain original spacing
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Comment header
                commentHeader
                
                // Comment body
                if isExpanded {
                    commentBody
                }
                // Show collapsed indicator when comment has children but is not expanded
                if comment.hasChildren && !isExpanded {
                    collapsedIndicator
                }
            }
            .contentShape(.rect)
        }
        .padding(.leading, isTopLevel ? 0 : 0) // Remove the original indentation since we're using rectangles
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .opacity(!isExpanded && comment.hasChildren ? 0.5 : 1.0)
    }
    
    private var commentHeader: some View {
        HStack {
            // Avatar logo or subreddit logo TODO:
//            Image(systemName: "person.crop.circle.fill")
//                .font(.title)
//                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if comment.stickied {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    
                    Text(comment.author)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            comment.distinguished == "moderator" ? .green :
                                (comment.isSubmitter ? .blue : .secondary)
                        )
                    
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
                .font(.caption2)
                .fontWeight(.medium)
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
            .id(comment.id)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(.background.secondary, in: .rect(cornerRadius: 14))
            .foregroundStyle(.secondary)
            .fontWeight(.semibold)
        }
    }
    
    private var commentBody: some View {
        Text(LocalizedStringKey(comment.body.trimmingCharacters(in: .whitespacesAndNewlines)))
            .font(.callout)
            .opacity(0.85)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var collapsedIndicator: some View {
        Text("[\(comment.totalChildCount) \(comment.totalChildCount == 1 ? "reply" : "replies")]")
            .font(.caption)
            .foregroundStyle(.secondary)
            .italic()
    }
    
    private var commentDivider: some View {
        Divider()
            .padding(.leading, isTopLevel ? 12 : CGFloat(min(comment.depth, maxDepth) * 12) + 12)
    }
    
    // Function to get color based on comment depth
    private func colorForDepth(_ depth: Int) -> Color {
        let colors: [Color] = [
            .blue,      // Depth 1
            .green,     // Depth 2
            .orange,    // Depth 3
            .purple,    // Depth 4
            .red,       // Depth 5
            .pink,      // Depth 6
            .teal,      // Depth 7
            .indigo     // Depth 8
        ]
        
        let index = (depth - 1) % colors.count
        return colors[index]
    }
}
