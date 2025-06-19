//
//  SubredditSearchResultView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct SubredditSearchResultView: View {
    @Environment(AppConfig.self) private var config
    let subreddit: Subreddit
    
    var body: some View {
        NavigationLink(value: subreddit) {
            Label {
                Text(subreddit.displayNamePrefixed)
            } icon: {
                if let url = subreddit.iconURL, let iconUrl = URL(string: url) {
                    AsyncImage(url: iconUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "r.circle")
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "r.circle")
                        .resizable()
                        .foregroundStyle(.secondary)
                        .frame(width: 40, height: 40)
                }
            }
        }
    }
}
