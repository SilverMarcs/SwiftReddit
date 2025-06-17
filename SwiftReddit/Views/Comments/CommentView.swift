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
                        commentDivider
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
                VStack(alignment: .leading, spacing: 0) {
                    commentContent
                    // Divider below comment content
                    commentDivider
                }
            }
        }
        .background(isTopLevel ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 12))
    }
    
    private var commentContent: some View {
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
        .padding(.leading, comment.depth < maxDepth ? comment.indentationWidth : CGFloat(maxDepth * 12))
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .opacity(!isExpanded && comment.hasChildren ? 0.5 : 1.0)
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
            .id(comment.id)
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
    
    private var commentDivider: some View {
        Divider()
            .padding(.leading, comment.depth < maxDepth ? comment.indentationWidth + 12 : CGFloat(maxDepth * 12) + 12)
    }
}

// Custom DisclosureGroup style for comments
struct CommentDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Clickable comment content with visual feedback
            Button {
//                withAnimation(.easeInOut(duration: 0.3)) {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
//                HStack {
                    configuration.label
//                    Spacer()
                    // Show chevron indicator for expandable comments
//                    Image(systemName: configuration.isExpanded ? "chevron.down" : "chevron.right")
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                        .animation(.easeInOut(duration: 0.2), value: configuration.isExpanded)
//                }
            }
            .buttonStyle(.plain)
            .contentShape(.rect)
            .accessibilityHint(configuration.isExpanded ? "Tap to collapse replies" : "Tap to expand replies")
            
            // Children comments (content) with smooth animation
            if configuration.isExpanded {
                configuration.content
//                    .transition(.asymmetric(
//                        insertion: .opacity.combined(with: .move(edge: .top)),
//                        removal: .opacity.combined(with: .move(edge: .top))
//                    ))
            }
        }
    }
}
