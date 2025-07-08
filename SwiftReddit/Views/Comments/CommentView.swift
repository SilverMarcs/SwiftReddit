//
//  CommentView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct CommentView: View {
    @Environment(Nav.self) var nav
    @State var comment: Comment
    @State private var isExpanded: Bool
    
    let onToggleCollapse: (Comment) -> Void
    let isTopLevel: Bool
    
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
                    ForEach(comment.children, id: \.id) { child in
                        CommentView(comment: child, onToggleCollapse: onToggleCollapse, isTopLevel: false)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        CommentContent(comment: comment, isTopLevel: isTopLevel, isExpanded: isExpanded)

                        if isExpanded {
                            Divider()
                                .padding(.leading, isTopLevel ? 12 : CGFloat(min(comment.depth, maxDepth) * 12) + 12)
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
                CommentContent(comment: comment, isTopLevel: isTopLevel, isExpanded: isExpanded)
            }
        }
        .background(isTopLevel ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 14))
    }
}
