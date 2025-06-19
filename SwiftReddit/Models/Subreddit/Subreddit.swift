//
//  Subreddit.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation

/// Subreddit model with only necessary properties
struct Subreddit: Identifiable, Hashable {
    let id: String
    let displayName: String
    let displayNamePrefixed: String
    let iconURL: String?
    let subscriberCount: Int
    let isSubscribed: Bool
    let publicDescription: String
    
    var postListingId: PostListingId {
        displayName
    }
    
    /// Convenience initializer that extracts necessary properties from SubredditData
    init(data: SubredditData) {
        self.id = data.id
        self.displayName = data.display_name ?? data.name
        self.displayNamePrefixed = data.display_name_prefixed ?? "r/\(self.displayName)"
        self.subscriberCount = data.subscribers ?? 0
        self.isSubscribed = data.user_is_subscriber ?? false
        self.publicDescription = data.public_description
        
        // Priority: community_icon > icon_img
        if let communityIcon = data.community_icon, !communityIcon.isEmpty {
            // Remove URL parameters if present
            self.iconURL = communityIcon.components(separatedBy: "?").first
        } else if let iconImg = data.icon_img, !iconImg.isEmpty {
            self.iconURL = iconImg.components(separatedBy: "?").first
        } else {
            self.iconURL = nil
        }
    }
    
    /// Convenience initializer that extracts necessary properties from SubredditDetail
    init(detail: SubredditDetail) {
        self.id = detail.id
        self.displayName = detail.display_name ?? ""
        self.displayNamePrefixed = detail.display_name_prefixed ?? "r/\(self.displayName)"
        self.subscriberCount = detail.subscribers ?? 0
        self.isSubscribed = detail.user_is_subscriber ?? false
        self.publicDescription = detail.public_description ?? ""
        
        // Priority: community_icon > icon_img
        if let communityIcon = detail.community_icon, !communityIcon.isEmpty {
            // Remove URL parameters if present
            self.iconURL = communityIcon.components(separatedBy: "?").first
        } else if let iconImg = detail.icon_img, !iconImg.isEmpty {
            self.iconURL = iconImg.components(separatedBy: "?").first
        } else {
            self.iconURL = nil
        }
    }
}
