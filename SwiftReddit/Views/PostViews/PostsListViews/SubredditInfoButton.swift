//
//  SubredditInfoButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import SwiftUI
import Kingfisher

struct SubredditInfoButton: View {
    let subreddit: Subreddit
    @State private var showingSubredditInfo = false
    
    var body: some View {
        Button {
            showingSubredditInfo = true
        } label: {
            if let url = URL(string: subreddit.iconURL ?? "") {
                KFImage(url)
                    .downsampling(size: CGSize(width: 30, height: 20))
                    .fade(duration: 0.1)
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
