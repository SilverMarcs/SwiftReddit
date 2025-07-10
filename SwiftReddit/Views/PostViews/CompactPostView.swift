//
//  CompactPostView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct CompactPostView: View {
    @Environment(Nav.self) var nav
    let post: Post
    
    var body: some View {
        Button {
            nav.path.append(post)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        SubredditButton(subreddit: post.subreddit, type: .text)
                            .font(.subheadline)
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text(post.created.timeAgo)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                    
                    // Title
                    Text(post.title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                            Text(post.ups.formatted)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                            Text(post.numComments.formatted)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if post.mediaType.isVisualMedia {
                    PostMediaView(mediaType: post.mediaType)
                        .frame(width: 60, height: 60)
                        .allowsHitTesting(false)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
