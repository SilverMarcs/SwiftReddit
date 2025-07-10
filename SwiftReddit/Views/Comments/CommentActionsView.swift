//
//  CommentActionsView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI
import Combine

struct CommentActionsView: View {
    let comment: Comment
    private var viewModel: VoteActionViewModel
    
    init(comment: Comment) {
        self.comment = comment
        viewModel = VoteActionViewModel(item: comment, targetType: .comment)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: { viewModel.vote(action: .up) }) {
                Image(systemName: "arrow.up")
                    .font(.subheadline)
                    .foregroundStyle(viewModel.likes == true ? .indigo : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(viewModel.upsCount.formatted())
                .contentTransition(.numericText())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(viewModel.likes == true ? .indigo : viewModel.likes == false ? .red : .secondary)
            
            Button(action: { viewModel.vote(action: .down) }) {
                Image(systemName: "arrow.down")
                    .font(.subheadline)
                    .foregroundStyle(viewModel.likes == false ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .id(comment.id)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.background.secondary, in: .rect(cornerRadius: 14))
        .fontWeight(.semibold)
    }
}
