//
//  PostDetail.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetail: View {
    @Environment(Nav.self) var nav
    
    var post: Post
    @State private var sortOption: CommentSortOption = .confidence
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                PostView(post: post, isCompact: false)
                
                CommentsListView(post: post, sortOption: sortOption)
                    .environment(\.openURL, OpenURLAction { url in
                        let linkMetadata = LinkMetadata(
                            url: url.absoluteString,
                            domain: url.host ?? "Unknown",
                            thumbnailURL: nil
                        )

            //                      nav.path.append(linkMetadata)
                                        nav.navigateToLink(linkMetadata)


                        return .handled
                    })
            }
        }
        .navigationTitle(post.subreddit.displayName)
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
