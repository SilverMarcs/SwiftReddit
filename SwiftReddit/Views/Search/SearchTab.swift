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
    @State private var searchResults: [Subreddit] = []
    @State private var isLoading = false
    @State private var hasSearched = false
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
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
                        Image(systemName: searchScope == .subreddits ? "magnifyingglass" : "person.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Search for \(searchScope.rawValue)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .listRowSeparator(.hidden)
                } else {
                    switch searchScope {
                    case .subreddits:
                        ForEach(searchResults) { subreddit in
//                            SubredditSearchResultView(subreddit: subreddit)
                            SubredditRowView(subreddit: subreddit)
                        }
                    case .users:
                        // Dummy user results for now
                        Text("To be implemented later")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search \(searchScope.rawValue)")
            .searchScopes($searchScope) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .navigationTitle("Search")
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationDestinations()
            .onSubmit(of: .search) {
                Task {
                    await performSearch(searchText)
                }
            }
            .onChange(of: searchScope) {
                searchResults = []
                hasSearched = false
            }
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Clear", role: .destructive) {
                        searchText = ""
                        searchResults = []
                        hasSearched = false
                    }
                    .disabled(searchText.isEmpty && searchResults.isEmpty)
                }
            }
        }
    }
    
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
        
        if let subreddits: [Subreddit] = await RedditAPI.shared.searchSubreddits(query, limit: 25) {
            searchResults = subreddits
        } else {
            searchResults = []
        }
    }
}

enum SearchScope: String, CaseIterable {
    case subreddits = "Subreddits"
    case users = "Users"
}

#Preview {
    SearchTab()
        .environment(Nav())
}
