import SwiftUI

struct CommentContent: View {
    let comment: Comment
    let isTopLevel: Bool
    let isExpanded: Bool
    let onReply: (Comment) -> Void
    
    private let maxDepth = 8
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if !isTopLevel && comment.depth > 0 {
                if comment.depth > 1 {
                    Spacer()
                        .frame(width: CGFloat((comment.depth - 1) * 12))
                }
                Rectangle()
                    .fill(Comment.colorForDepth(comment.depth))
                    .frame(width: 2)
                    .padding(.trailing, 9)
            }
            VStack(alignment: .leading, spacing: 8) {
                CommentHeader(comment: comment)
                if isExpanded {
                    Text(LocalizedStringKey(comment.body))
                        .font(.callout)
                        .opacity(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                        .handleURLs()
                }
                if comment.hasChildren && !isExpanded {
                    Text("[\(comment.totalChildCount) \(comment.totalChildCount == 1 ? "reply" : "replies")]")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
            .contentShape(.rect)
        }
        .padding(.leading, isTopLevel ? 0 : 0)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .opacity(!isExpanded && comment.hasChildren ? 0.5 : 1.0)
        .contextMenu {
            Button {
                onReply(comment)
            } label: {
                Label("Reply", systemImage: "arrowshape.turn.up.backward.fill")
            }
        }
    }
}
