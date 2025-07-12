//
//  PostListToolbar.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import SwiftUI
import Kingfisher

struct PostListToolbar: ToolbarContent {
    let feedType: PostFeedType
    @Binding var selectedSort: SubListingSortOption
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            if feedType.canSort {
                SortMenuButton(selectedSort: $selectedSort)
            }
            
            if let subreddit = feedType.subreddit, subreddit.isDetailed {
                SubredditInfoButton(subreddit: subreddit)
            }
        }
    }
}
