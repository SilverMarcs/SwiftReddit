//
//  PostRepostView.swift
//  SwiftReddit
//
//  Created by SwiftReddit Team on 18/06/2025.
//

import SwiftUI

struct PostRepostView: View {
    @Environment(AppConfig.self) private var config
    let originalPost: Post
    
    var body: some View {
        Button {
            config.path.append(originalPost)
                
        } label: {
            VStack(alignment: .leading) {
                // Repost header
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    
                    Text(originalPost.subredditNamePrefixed)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(originalPost.formattedUps)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                // Original post content preview
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(originalPost.title)
                        .font(.headline)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
//                     Post metadata
//                    HStack {
//                        Text("u/\(originalPost.author)")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                        
//                        Text("•")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                        
//                        Text(originalPost.timeAgo)
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                        
//                        Spacer()
//                        
//                        // Vote count
//                        HStack(spacing: 4) {
//                            Image(systemName: "arrow.up")
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                            Text(originalPost.formattedUps)
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                        }
//                    }
                    
                    // Show original post's media if it has any (but smaller)
                    if originalPost.mediaType.hasMedia && !isRepostOfRepost(originalPost.mediaType) {
                        PostMediaView(mediaType: originalPost.mediaType)
                            .frame(maxHeight: 120)
                            .clipped()
                            .cornerRadius(8)
                    }
                    
                    // Selftext preview for text posts
                    if originalPost.isSelf && !originalPost.selftext.isEmpty {
                        Text(originalPost.selftext)
                            .font(.body)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(
                    cornerRadius: 12,
                )
                .fill(.background.secondary)
//                .stroke(.separator, lineWidth: 1)

            )
        }
        .buttonStyle(.plain)
    }
    
    // Helper to prevent infinite nesting of reposts
    private func isRepostOfRepost(_ mediaType: MediaType) -> Bool {
        if case .repost = mediaType {
            return true
        }
        return false
    }
}
