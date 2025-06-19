//
//  SubredditSearchResultView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct SubredditSearchResultView: View {
    @Environment(Nav.self) private var nav
    let subreddit: Subreddit
    
    var body: some View {
        Button {
            nav.navigateToSubreddit(subreddit)
        } label: {
            Label {
                Text(subreddit.displayNamePrefixed)
            } icon: {
//                if let url = subreddit.iconURL, let iconUrl = URL(string: url) {
////                    CachedAsyncImage(url: iconUrl)
////                        .frame(width: 40, height: 40)
////                        .clipShape(Circle())
//
//                    AsyncImage(url: iconUrl) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    } placeholder: {
//                        Image(systemName: "r.circle")
//                            .foregroundStyle(.secondary)
//                    }
//                    .frame(width: 40, height: 40)
//                    .clipShape(Circle())
//                } else {
                    Image(systemName: "r.circle")
                        .resizable()
                        .foregroundStyle(.secondary)
                        .frame(width: 40, height: 40)
//                }
            }
        }
    }
}
