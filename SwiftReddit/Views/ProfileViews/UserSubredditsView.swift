//
//  UserSubredditsView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI
import Kingfisher

struct UserSubredditsView: View {
    @Environment(Nav.self) private var nav
    @State private var subreddits: [Subreddit] = []
    @State private var isLoading = false
    
    // Group subreddits alphabetically
    private var groupedSubreddits: [String: [Subreddit]] {
        Dictionary(grouping: subreddits) { subreddit in
            String(subreddit.displayName.prefix(1).uppercased())
        }
    }
    
    // Get sorted section keys
    private var sortedSectionKeys: [String] {
        groupedSubreddits.keys.sorted()
    }
    
    var body: some View {
        List {
            Section {
               NavigationLink {
                   PostsList(feedType: .saved)
               } label: {
                   Label("Saved Posts", systemImage: "bookmark")
               }
           }
            .listSectionMargins(.top, 5)
            
            if isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(sortedSectionKeys, id: \.self) { letter in
                    Section(letter) {
                        if let subredditsInSection = groupedSubreddits[letter] {
                            ForEach(subredditsInSection.sorted { $0.displayName < $1.displayName }, id: \.id) { subreddit in
                                SubredditRowView(subreddit: subreddit)
                            }
                        }
                    }
                    .sectionIndexLabel(letter)
                }
            }
        }
        .task {
            guard subreddits.isEmpty else { return }
            await fetchSubreddits()
        }
        .refreshable {
            await fetchSubreddits()
        }
    }
    
    private func fetchSubreddits() async {
        isLoading = true
        defer { isLoading = false }
        
        if let fetchedSubreddits = await RedditAPI.shared.fetchUserSubreddits() {
            subreddits = fetchedSubreddits.filter { $0.isSubscribed }
        }
    }
}
