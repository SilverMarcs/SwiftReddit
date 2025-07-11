//
//  Subreddit.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation
import SwiftUI

/// Subreddit model with only necessary properties
struct Subreddit: Identifiable, Hashable {
    let id: String
    let displayName: String
    let displayNamePrefixed: String
    let iconURL: String?
    let subscriberCount: Int
    let isSubscribed: Bool
    let publicDescription: String
    let color: Color?
    
    /// Special instance for home feed
    static let home = Subreddit(
        id: "home",
        displayName: "",
        displayNamePrefixed: "Home",
        iconURL: nil,
        subscriberCount: 0,
        isSubscribed: false,
        publicDescription: "Your personalized home feed",
        color: nil
    )
    
    /// Direct initializer for creating Subreddit instances
    init(id: String, displayName: String, displayNamePrefixed: String, iconURL: String?, subscriberCount: Int, isSubscribed: Bool, publicDescription: String, color: Color?) {
        self.id = id
        self.displayName = displayName
        self.displayNamePrefixed = displayNamePrefixed
        self.iconURL = iconURL
        self.subscriberCount = subscriberCount
        self.isSubscribed = isSubscribed
        self.publicDescription = publicDescription
        self.color = color
    }
    
    /// Convenience initializer that extracts necessary properties from SubredditData
    init(data: SubredditData) {
        self.id = data.id
        self.displayName = data.display_name ?? data.name
        self.displayNamePrefixed = data.display_name_prefixed ?? "r/\(self.displayName)"
        self.subscriberCount = data.subscribers ?? 0
        self.isSubscribed = data.user_is_subscriber ?? false
        self.publicDescription = data.public_description
        
        // Convert key_color hex string to SwiftUI Color
        if let keyColor = data.key_color, !keyColor.isEmpty {
            self.color = Subreddit.validateColor(from: keyColor)
        } else {
            self.color = nil
        }
        
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
        
        // Convert key_color hex string to SwiftUI Color
        if let keyColor = detail.key_color, !keyColor.isEmpty {
            self.color = Subreddit.validateColor(from: keyColor)
        } else {
            self.color = nil
        }
        
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
    
    /// Convenience initializer for creating a simple Subreddit with just a display name
    init(displayName: String) {
        self.id = displayName.isEmpty ? "home" : displayName
        self.displayName = displayName
        self.displayNamePrefixed = displayName.isEmpty ? "Home" : "r/\(displayName)"
        self.iconURL = nil
        self.subscriberCount = 0
        self.isSubscribed = false
        self.publicDescription = ""
        self.color = nil
    }
    
    /// Convenience initializer for basic subreddit info when sr_detail is not available
    init(displayName: String, displayNamePrefixed: String?) {
        self.id = displayName
        self.displayName = displayName
        self.displayNamePrefixed = displayNamePrefixed ?? "r/\(displayName)"
        self.iconURL = nil
        self.subscriberCount = 0
        self.isSubscribed = false
        self.publicDescription = ""
        self.color = nil
    }
    
    /// Helper method to validate and convert key_color to SwiftUI Color
    private static func validateColor(from keyColor: String?) -> Color? {
        return Color.validatedColor(from: keyColor)
    }
}
