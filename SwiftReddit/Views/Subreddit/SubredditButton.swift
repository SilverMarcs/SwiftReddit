//
//  SubredditButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI
import Kingfisher

struct SubredditButton: View {
    @Environment(Nav.self) private var nav
    let subreddit: Subreddit
    let type: SubRedditButtonType
    
    var body: some View {
        Button {
            nav.path.append(subreddit)
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
                                   .foregroundStyle(.secondary)
                                   .clipShape(Circle())
            //                    .aspectRatio(aspectRatio, contentMode: .fit) // Use known aspect ratio
                        }
                        .downsampling(size: CGSize(width: 32, height: 32))
                        .processingQueue(.dispatch(.global()))
                        .fade(duration: 0.1)
                        .clipShape(Circle())
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(maxHeight: 500)
                    
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
