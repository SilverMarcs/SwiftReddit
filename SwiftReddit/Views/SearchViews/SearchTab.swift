//
//  SearchTab.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct SearchTab: View {
    @Environment(Nav.self) private var nav
    @State private var searchText = ""
    @State private var searchScope: SearchScope = .subreddits
    @State private var subredditResults: [Subreddit] = []
    @State private var postResults: [Post] = []
    @State private var isLoading = false
    
    var searchResults: [Any] {
        switch searchScope {
        case .subreddits:
            return subredditResults
        case .posts:
            return postResults
        }
    }
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            List {
                if isLoading {
                    LoadingIndicator()
                } else {
                    switch searchScope {
                    case .subreddits:
                        ForEach(subredditResults) { subreddit in
                            SubredditRowView(subreddit: subreddit)
                        }
                    case .posts:
                        ForEach(postResults) { post in
                            CompactPostView(post: post)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .toolbarTitleDisplayMode(.inlineLarge)
            .searchable(text: $searchText, prompt: "Search \(searchScope.rawValue)")
            .searchScopes($searchScope) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .onSubmit(of: .search) {
                Task {
                    await performSearch()
                }
            }
            .onChange(of: searchScope) {
                subredditResults = []
                postResults = []
                Task {
                    await performSearch()
                }
            }
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Clear", role: .destructive) {
                        searchText = ""
                        subredditResults = []
                        postResults = []
                    }
                    .disabled(searchText.isEmpty && searchResults.isEmpty)
                }
            }
            .navigationDestinations()
        }
    }
    
    private func performSearch() async {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            subredditResults = []
            postResults = []
            return
        }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        switch searchScope {
        case .subreddits:
            if let subreddits = await RedditAPI.shared.searchSubreddits(searchText, limit: 25) {
                subredditResults = subreddits
            } else {
                subredditResults = []
            }
        case .posts:
            if let posts = await RedditAPI.shared.searchPosts(searchText, limit: 25) {
                postResults = posts
            } else {
                postResults = []
            }
        }
    }
}

enum SearchScope: String, CaseIterable {
    case subreddits = "Subreddits"
    case posts = "Posts"
}
