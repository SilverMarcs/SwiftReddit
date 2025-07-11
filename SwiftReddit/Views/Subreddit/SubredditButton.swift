//
//  SubredditButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI
import Kingfisher

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
                    .font(.caption)
                    .foregroundStyle(subreddit.color ?? .blue)
            case .icon(let iconURL):
                if let url = URL(string: iconURL) {
                    KFImage(url)
                        .placeholder { // during loading
                            Image(systemName: "r.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(subreddit.color ?? .secondary)
                               .clipShape(Circle())
                        }
                        .downsampling(size: CGSize(width: 60, height: 60))
                        .fade(duration: 0.1)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "r.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .font(.title)
                        .foregroundStyle(.secondary)
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
