//
//  SearchTab.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct SearchTab: View {
    @Environment(AppConfig.self) private var config
    @State private var searchText = ""
    @State private var searchResults: [Subreddit] = []
    @State private var isLoading = false
    @State private var hasSearched = false
    
    var body: some View {
        @Bindable var config = config
        
        NavigationStack(path: $config.path) {
            List {
                if isLoading {
                    ProgressView()
                        .controlSize(.large)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                } else if hasSearched && searchResults.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search
                } else if !hasSearched && searchText.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Search for Subreddits")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(searchResults) { subreddit in
                        SubredditSearchResultView(subreddit: subreddit)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Subreddits")
            .navigationTitle("Search")
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationDestinations()
            .onSubmit(of: .search) {
                Task {
                    await performSearch(searchText)
                }
            }
        }
    }
    
    @MainActor
    private func performSearch(_ query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            hasSearched = false
            return
        }
        
        isLoading = true
        hasSearched = true
        
        defer {
            isLoading = false
        }
        
        if let subredditData = await RedditAPI.shared.searchSubreddits(query, limit: 25) {
            searchResults = subredditData.map { Subreddit(data: $0) }
        } else {
            searchResults = []
        }
    }
}

#Preview {
    SearchTab()
        .environment(AppConfig())
}
