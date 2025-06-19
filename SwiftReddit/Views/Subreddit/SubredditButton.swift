//
//  SubredditButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct SubredditButton: View {
    @Environment(Nav.self) private var nav
    let subreddit: Subreddit
    let type: SubRedditButtonType
    
    var body: some View {
        Button {
            nav.navigateToSubreddit(subreddit)
        } label: {
            switch type {
            case .text:
                Text(subreddit.displayNamePrefixed)
                    .font(.caption)
                    .foregroundStyle(.link)
            case .icon(let iconURL):
                if let url = URL(string: iconURL) {
                     CachedAsyncImage(url: url)
                         .frame(width: 32, height: 32)
                         .clipShape(Circle())
                    
//                    AsyncImage(url: url) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    } placeholder: {
//                        Image(systemName: "r.circle")
//                            .foregroundStyle(.secondary)
//                    }
//                    .frame(width: 32, height: 32)
//                    .clipShape(Circle())
                } else {
                    Image(systemName: "r.circle")
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
