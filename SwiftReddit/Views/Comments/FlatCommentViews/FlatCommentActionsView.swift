//
//  FlatCommentActionsView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct FlatCommentActionsView: View {
    let comment: FlatComment
    @State private var likes: Bool?
    @State private var upsCount: Int
    
    init(comment: FlatComment) {
        self.comment = comment
        self._likes = State(initialValue: comment.likes)
        self._upsCount = State(initialValue: comment.ups)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: { 
                // Handle upvote
                if likes == true {
                    likes = nil
                    upsCount = comment.ups
                } else {
                    likes = true
                    upsCount = comment.ups + (comment.likes == false ? 2 : 1)
                }
            }) {
                Image(systemName: "arrow.up")
                    .font(.subheadline)
                    .foregroundStyle(likes == true ? .indigo : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(upsCount.formatted)
                .contentTransition(.numericText())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(likes == true ? .indigo : likes == false ? .red : .secondary)
            
            Button(action: { 
                // Handle downvote
                if likes == false {
                    likes = nil
                    upsCount = comment.ups
                } else {
                    likes = false
                    upsCount = comment.ups - (comment.likes == true ? 2 : 1)
                }
            }) {
                Image(systemName: "arrow.down")
                    .font(.subheadline)
                    .foregroundStyle(likes == false ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .fontWeight(.semibold)
        .padding(8)
        .glassEffect()
    }
}
