//
//  PostDetail.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetailView: View {
    @Environment(Nav.self) var nav
    
    @State private var dataSource: PostDetailDataSource
    @State private var showCommentSheet = false
    
    init(post: Post) {
        self._dataSource = State(initialValue: PostDetailDataSource(post: post))
    }
    
    init(postNavigation: PostNavigation) {
        self._dataSource = State(initialValue: PostDetailDataSource(postNavigation: postNavigation))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if let post = dataSource.post {
                    PostView(
                        post: post,
                        isCompact: false,
                        onReplyTap: { showCommentSheet = true }
                    )
                    
                    Divider()
                }
                
                if dataSource.isLoading {
                    LoadingIndicator()
                        .id(UUID())
                    
                } else if !dataSource.visibleComments.isEmpty {
                    Text("Comments")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)

                    ForEach(dataSource.visibleComments) { comment in
                        VStack(spacing: 8) {
                            if comment.depth == 0 && comment.id != dataSource.visibleComments.first?.id {
                                Rectangle()
                                    .fill(.background.secondary)
                                    .frame(height: 6)
                                    .padding(.horizontal, -15)
                            } else if comment.id != dataSource.visibleComments.first?.id {
                                Divider()
                            }
                            
                            CommentView(
                                comment: comment,
                                isCollapsed: dataSource.collapsedCommentIds.contains(comment.id)
                            ) { commentId in
                                dataSource.toggleCommentCollapse(commentId)
                            }
                            .environment(\.addOptimisticComment, dataSource.addOptimisticComment)
                        }
                    }
                }
            }
            .scenePadding(.horizontal)
            .scenePadding(.bottom)
            .scrollTargetLayout()
        }
        .scrollPosition($dataSource.scrollPosition)
        .task {
            if dataSource.allComments.isEmpty {
                await dataSource.loadComments()
            }
        }
        .onChange(of: dataSource.sortOption) {
            Task {
                await dataSource.loadComments()
            }
        }
        .refreshable {
            await dataSource.loadComments()
        }
        .navigationTitle(dataSource.post?.subreddit.displayNamePrefixed ?? "Post")
        .navigationSubtitle(dataSource.post?.numComments.formatted.appending(" comments") ?? "Loading...")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(CommentSortOption.allCases, id: \.self) { option in
                        Button {
                            dataSource.sortOption = option
                        } label: {
                            Label(option.displayName, systemImage: option.iconName)
                                .tag(option)
                        }
                    }
                } label: {
                    Label("Sort by", systemImage: dataSource.sortOption.iconName)
                        .labelStyle(.iconOnly)
                }
                .tint(.accent)
            }
        }
        .sheet(isPresented: $showCommentSheet) {
            if let post = dataSource.post {
                ReplySheet(parentId: post.id, isTopLevel: true) { text, postId in
                    dataSource.addOptimisticTopLevelComment(text: text, postId: postId)
                }
            }
        }
    }
}
