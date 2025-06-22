//
//  SubredditSearchResultView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI
import Kingfisher

struct SubredditSearchResultView: View {
    @Environment(Nav.self) private var nav
    let subreddit: Subreddit
    
    var body: some View {
        Button {
            nav.path.append(subreddit)
        } label: {
            HStack {
                Label {
                    Text(subreddit.displayNamePrefixed)
                    Text("\(subreddit.subscriberCount.formatted()) subscribers")
                } icon: {
                    if let url = URL(string: subreddit.iconURL ?? "") {
                        KFImage(url)
                            .downsampling(size: CGSize(width: 40, height: 40))
                            .processingQueue(.dispatch(.global()))
                            .fade(duration: 0.1)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "r.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.secondary)
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
