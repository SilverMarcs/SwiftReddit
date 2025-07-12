//
//  CompactPostView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI
import Kingfisher

struct CompactPostView: View {
    @Environment(\.appendToPath) var appendToPath
    let post: Post
    
    var body: some View {
        Button {
            appendToPath(post)
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
                
                if let url = post.mediaType.firstMediaURL, let mediaURL = URL(string: url) {
                    KFImage(mediaURL)
                        .placeholder {
                            Rectangle()
                                .fill(.background.secondary)
                                .frame(width: 70, height: 70)
                                .aspectRatio(1, contentMode: .fill)
                                .cornerRadius(12)
                                .clipped()
                                .overlay(
                                    ProgressView()
                                )
                        }
                        .downsampling(size: CGSize(width: 1000, height: 1000))
                        .serialize(as: .JPEG)
                        .fade(duration: 0.1)
                        .resizable()
                        .frame(width: 70, height: 70)
                        .aspectRatio(1, contentMode: .fill)
                        .cornerRadius(12)
                        .clipped()
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
