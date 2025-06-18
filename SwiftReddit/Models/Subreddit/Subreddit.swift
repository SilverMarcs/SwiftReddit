//
//  Subreddit.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation

/// Subreddit model wrapper for SubredditData
struct Subreddit: Identifiable, Hashable {
    let data: SubredditData
    
    var id: String { data.id }
    
    var displayName: String {
        data.display_name ?? data.name
    }
    
    var displayNamePrefixed: String {
        data.display_name_prefixed ?? "r/\(displayName)"
    }
    
    var iconURL: String? {
        // Priority: community_icon > icon_img
        if let communityIcon = data.community_icon, !communityIcon.isEmpty {
            // Remove URL parameters if present
            return communityIcon.components(separatedBy: "?").first
        }
        
        if let iconImg = data.icon_img, !iconImg.isEmpty {
            return iconImg.components(separatedBy: "?").first
        }
        
        return nil
    }
    
    var subscriberCount: Int {
        data.subscribers ?? 0
    }
    
    var isSubscribed: Bool {
        data.user_is_subscriber ?? false
    }
    
    var publicDescription: String {
        data.public_description
    }
    
    var postListingId: PostListingId {
        displayName
    }
    
    init(data: SubredditData) {
        self.data = data
    }
}
