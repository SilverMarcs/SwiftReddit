//
//  FlatCommentView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct FlatCommentView: View {
    let comment: FlatComment
    let onToggleCollapse: (String) -> Void
    
    @State private var showReplySheet = false
    
    private let maxDepth = 8
    
    var body: some View {
        Button {
            if comment.hasChildren {
                withAnimation(.easeInOut(duration: 0.2)) {
                    onToggleCollapse(comment.id)
                }
            }
        } label: {
            HStack(alignment: .top, spacing: 0) {
                // Visual depth indicator
                if comment.depth > 0 {
                    if comment.depth > 1 {
                        Spacer()
                            .frame(width: CGFloat((comment.depth - 1) * 12))
                    }
                    Rectangle()
                        .fill(FlatComment.colorForDepth(comment.depth))
                        .frame(width: 2)
                        .padding(.trailing, 9)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    FlatCommentHeader(comment: comment)
                    
                    if !comment.isCollapsed {
                        Text(LocalizedStringKey(comment.body))
                            .font(.callout)
                            .opacity(0.85)
                            .fixedSize(horizontal: false, vertical: true)
                            .handleURLs()
                    }
                    
                    if comment.hasChildren && comment.isCollapsed {
                        Text("[\(comment.childCount) \(comment.childCount == 1 ? "reply" : "replies")]")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }
                .contentShape(.rect)
                
                Spacer()
            }
            .id(comment.id)
            .opacity(comment.isCollapsed && comment.hasChildren ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                showReplySheet = true
            } label: {
                Label("Reply", systemImage: "arrowshape.turn.up.left")
            }
        }
        .sheet(isPresented: $showReplySheet) {
            ReplySheet(parentId: comment.id)
                .presentationDetents([.medium])
        }
    }
}
