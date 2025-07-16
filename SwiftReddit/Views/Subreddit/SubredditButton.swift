//
//  SubredditButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct SubredditButton: View {
    @Environment(\.appendToPath) var appendToPath
    let subreddit: Subreddit
    let type: SubRedditButtonType
    
    var body: some View {
        Button {
            appendToPath(PostFeedType.subreddit(subreddit))
        } label: {
            switch type {
            case .text:
                Text(subreddit.displayNamePrefixed)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(subreddit.color ?? .blue)
            case .icon(let iconURL):
                if let url = URL(string: iconURL) {
                    CachedImageView(url: url, targetSize: CGSize(width: 50, height: 50))
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "r.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .font(.title)
                        .foregroundStyle(subreddit.color ?? .blue)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

enum SubRedditButtonType {
    case icon(iconUrl: String)
    case text
}
