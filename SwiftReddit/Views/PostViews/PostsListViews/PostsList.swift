//
//  PostsList.swift
//  SwiftReddit
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct PostsList: View {
    @Environment(Nav.self) private var nav
    @State private var dataSource: PostListDataSource
    @State private var selectedSort: SubListingSortOption = .best
    
    private let feedType: PostFeedType
    
    init(feedType: PostFeedType) {
        self.feedType = feedType
        self._dataSource = State(initialValue: PostListDataSource(feedType: feedType))
    }
    
    var body: some View {
        List {
            ForEach(dataSource.posts) { post in
                Button {
                    nav.path.append(post)
                } label: {
                    PostView(post: post)
                        .navigationLinkIndicatorVisibility(.hidden)
                        #if !os(macOS)
                        .contentShape(.contextMenuPreview, .rect(cornerRadius: 16))
                        #endif
                }
                .buttonStyle(.plain)
                .listRowInsets(.vertical, 5)
                .listRowInsets(.horizontal, 6)
            }
            .listRowSeparator(.hidden)
            
            // Inline load more trigger
            Color.clear
                .frame(height: 1)
                .onAppear {
                    if !dataSource.isLoading && dataSource.after != nil {
                        Task {
                            await dataSource.loadMorePosts()
                        }
                    }
                }
                .listRowSeparator(.hidden)
            
            if dataSource.isLoading {
                LoadingIndicator()
            }
        }
        .listStyle(.plain)
        .navigationTitle(feedType.displayName)
        .toolbarTitleDisplayMode(.inlineLarge)
        .refreshable {
            await dataSource.refreshPosts()
        }
        .task(id: selectedSort) {
            dataSource.updateSort(selectedSort)
            await dataSource.loadInitialPosts()
        }
        .toolbar {
            PostListToolbar(feedType: feedType, selectedSort: $selectedSort)
        }
    }
}
