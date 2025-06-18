//
//  PostDetail.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetail: View {
    var post: Post
    @State private var sortOption: CommentSortOption = .confidence
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                PostView(post: post, showBackground: false, truncateSelfText: false)
                
                // Comments
                CommentsListView(post: post, sortOption: sortOption)
            }
        }
        .navigationTitle(post.subreddit)
        .navigationSubtitle(post.formattedComments + " comments")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(CommentSortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            Label(option.displayName, systemImage: option.iconName)
                                .tag(option)
                        }
                    }
                } label: {
                    Label("Sort by", systemImage: sortOption.iconName)
                        .labelStyle(.iconOnly)
                }
                .tint(.accent)
            }
        }
    }
}

//#Preview {
//    PostDetail()
//}
