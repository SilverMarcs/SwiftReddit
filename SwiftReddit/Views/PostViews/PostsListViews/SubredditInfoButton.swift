//
//  SubredditInfoButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import SwiftUI

struct SubredditInfoButton: View {
    let subreddit: Subreddit
    @State private var showingSubredditInfo = false
    
    var body: some View {
        Button {
            showingSubredditInfo = true
        } label: {
            if let url = URL(string: subreddit.iconURL ?? "") {
                CachedImageView(url: url, targetSize: CGSize(width: 50, height: 50))
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                Image(systemName: "info.circle")
                    .tint(subreddit.color ?? .blue)
            }
        }
        .sheet(isPresented: $showingSubredditInfo) {
            SubredditInfoView(subreddit: subreddit)
        }
    }
}
