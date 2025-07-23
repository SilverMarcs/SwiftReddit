//
//  PostsList.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import SwiftUI

struct PostsList: View {
    @Environment(\.appendToPath) var appendToPath
    @State private var dataSource: PostListDataSource
    
    private let feedType: PostFeedType
    
    init(feedType: PostFeedType) {
        self.feedType = feedType
        self._dataSource = State(initialValue: PostListDataSource(feedType: feedType))
    }
    
    var body: some View {
        List {
            ForEach(dataSource.posts) { post in
                Button {
                    appendToPath(post)
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
                    .id(UUID())
            }
        }
        #if os(macOS)
        .frame(maxWidth: 600)
        .scrollIndicators(.hidden)
        #endif
        .listStyle(.plain)
        .navigationTitle(feedType.displayName)
        .toolbarTitleDisplayMode(.inlineLarge)
        .refreshable {
            await dataSource.refreshPosts()
        }
        .task {
            if dataSource.posts.isEmpty {
                await dataSource.loadInitialPosts()
            }
        }
        .onChange(of: dataSource.currentSort) {
            Task {
                await dataSource.loadInitialPosts()
            }
        }
        .toolbar {
            PostListToolbar(feedType: feedType, selectedSort: $dataSource.currentSort)
        }
    }
}
