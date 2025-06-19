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
            HStack {
                Label {
                    Text(subreddit.displayNamePrefixed)
                    Text("\(subreddit.subscriberCount.formatted()) subscribers")
                } icon: {
                    Image(systemName: "r.circle")
                        .foregroundStyle(subreddit.color ?? .accent)
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
