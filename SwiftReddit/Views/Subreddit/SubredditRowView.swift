//
//  SubredditRowView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI
import Kingfisher

struct SubredditRowView: View {
    @Environment(Nav.self) private var nav
    let subreddit: Subreddit
    
    var body: some View {
        Button {
            nav.path.append(PostFeedType.subreddit(subreddit))
        } label: {
            HStack {
                Label {
                    Text(subreddit.displayNamePrefixed)
                    Text("\(subreddit.subscriberCount.formatted()) subscribers")
                } icon : {
                    if let iconURL = subreddit.iconURL, let url = URL(string: iconURL) {
                        KFImage(url)
                            .downsampling(size: CGSize(width: 32, height: 32))
//                            .processingQueue(.dispatch(.global()))
                            .fade(duration: 0.1)
                            .clipShape(Circle())
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "r.circle")
                            .foregroundStyle(subreddit.color ?? .secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
