//
//  PostDetail.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetail: View {
    var post: Post
    
    var body: some View {
        List {
            Section {
                PostView(post: post, showBackground: false, truncateSelfText: false)
                    .listRowInsets(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5))
                    .listRowSeparator(.hidden)
            }
            
            Section {
                ForEach(0..<post.numComments, id: \.self) { index in
                    Text("Comment \(index + 1)")
                        .padding()
                }
            }   
        }
        .navigationTitle(post.subreddit)
        .navigationSubtitle(post.formattedComments + " comments")
        .toolbarTitleDisplayMode(.inline)
        .listStyle(.plain)
    }
}

//#Preview {
//    PostDetail()
//}
