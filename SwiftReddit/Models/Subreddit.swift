//
//  Subreddit.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import Foundation

/// Simplified Subreddit model for basic functionality
struct Subreddit: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let displayName: String?
    let displayNamePrefixed: String?
    let title: String?
    let publicDescription: String
    let description: String?
    let subscribers: Int?
    let activeUserCount: Int?
    let over18: Bool?
    let iconImg: String?
    let communityIcon: String?
    let bannerImg: String?
    let primaryColor: String?
    let keyColor: String?
    let headerImg: String?
    let created: Double?
    let createdUTC: Double?
    let subredditType: String
    let userIsSubscriber: Bool?
    let userIsModerator: Bool?
    let userIsBanned: Bool?
    let userHasFavorited: Bool?
    let allowImages: Bool?
    let allowVideos: Bool?
    let allowGalleries: Bool?
    let allowPolls: Bool?
    let restrictPosting: Bool?
    let restrictCommenting: Bool?
    let wikiEnabled: Bool?
    let quarantine: Bool?
    let hideAds: Bool?
    let showMedia: Bool?
    let showMediaPreview: Bool?
    let spoilersEnabled: Bool?
    let allowTalks: Bool?
    let url: String
    
    init(id: String) {
        self.id = id
        self.name = id
        self.displayName = id
        self.displayNamePrefixed = "r/\(id)"
        self.title = id
        self.publicDescription = ""
        self.description = nil
        self.subscribers = nil
        self.activeUserCount = nil
        self.over18 = false
        self.iconImg = nil
        self.communityIcon = nil
        self.bannerImg = nil
        self.primaryColor = nil
        self.keyColor = nil
        self.headerImg = nil
        self.created = nil
        self.createdUTC = nil
        self.subredditType = "public"
        self.userIsSubscriber = nil
        self.userIsModerator = nil
        self.userIsBanned = nil
        self.userHasFavorited = nil
        self.allowImages = nil
        self.allowVideos = nil
        self.allowGalleries = nil
        self.allowPolls = nil
        self.restrictPosting = nil
        self.restrictCommenting = nil
        self.wikiEnabled = nil
        self.quarantine = false
        self.hideAds = nil
        self.showMedia = nil
        self.showMediaPreview = nil
        self.spoilersEnabled = nil
        self.allowTalks = nil
        self.url = id == "home" ? "" : "/r/\(id)"
    }
    
    init(from subredditData: SubredditData) {
        self.id = subredditData.id
        self.name = subredditData.name
        self.displayName = subredditData.display_name
        self.displayNamePrefixed = subredditData.display_name_prefixed
        self.title = subredditData.title
        self.publicDescription = subredditData.public_description
        self.description = subredditData.description
        self.subscribers = subredditData.subscribers
        self.activeUserCount = subredditData.active_user_count
        self.over18 = subredditData.over18
        self.iconImg = subredditData.icon_img
        self.communityIcon = subredditData.community_icon
        self.bannerImg = subredditData.banner_img
        self.primaryColor = subredditData.primary_color
        self.keyColor = subredditData.key_color
        self.headerImg = subredditData.header_img
        self.created = subredditData.created
        self.createdUTC = subredditData.created_utc
        self.subredditType = subredditData.subreddit_type
        self.userIsSubscriber = subredditData.user_is_subscriber
        self.userIsModerator = subredditData.user_is_moderator
        self.userIsBanned = subredditData.user_is_banned
        self.userHasFavorited = subredditData.user_has_favorited
        self.allowImages = subredditData.allow_images
        self.allowVideos = subredditData.allow_videos
        self.allowGalleries = subredditData.allow_galleries
        self.allowPolls = subredditData.allow_polls
        self.restrictPosting = subredditData.restrict_posting
        self.restrictCommenting = subredditData.restrict_commenting
        self.wikiEnabled = subredditData.wiki_enabled
        self.quarantine = subredditData.quarantine ?? false
        self.hideAds = subredditData.hide_ads
        self.showMedia = subredditData.show_media
        self.showMediaPreview = subredditData.show_media_preview
        self.spoilersEnabled = subredditData.spoilers_enabled
        self.allowTalks = subredditData.allow_talks
        self.url = subredditData.url
    }
    
    /// Get the appropriate icon URL
    var iconURL: String? {
        return communityIcon ?? iconImg
    }
    
    /// Get formatted subscriber count
    var formattedSubscribers: String {
        guard let subscribers = subscribers else { return "unknown" }
        
        if subscribers >= 1_000_000 {
            return String(format: "%.1fM", Double(subscribers) / 1_000_000.0)
        } else if subscribers >= 1_000 {
            return String(format: "%.1fk", Double(subscribers) / 1_000.0)
        }
        return String(subscribers)
    }
}

/// SubredditData structure matching Reddit API
struct SubredditData: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let display_name: String?
    let display_name_prefixed: String?
    let title: String?
    let public_description: String
    let description: String?
    let subscribers: Int?
    let active_user_count: Int?
    let over18: Bool?
    let icon_img: String?
    let community_icon: String?
    let banner_img: String?
    let primary_color: String?
    let key_color: String?
    let header_img: String?
    let created: Double?
    let created_utc: Double?
    let subreddit_type: String
    let user_is_subscriber: Bool?
    let user_is_moderator: Bool?
    let user_is_banned: Bool?
    let user_has_favorited: Bool?
    let allow_images: Bool?
    let allow_videos: Bool?
    let allow_galleries: Bool?
    let allow_polls: Bool?
    let restrict_posting: Bool?
    let restrict_commenting: Bool?
    let wiki_enabled: Bool?
    let quarantine: Bool?
    let hide_ads: Bool?
    let show_media: Bool?
    let show_media_preview: Bool?
    let spoilers_enabled: Bool?
    let allow_talks: Bool?
    let url: String
}

/// Sort options for subreddit posts
enum SubListingSortOption: String, CaseIterable, Identifiable {
    case best = "best"
    case hot = "hot"
    case new = "new"
    case controversial = "controversial"
    case top = "top"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .best: return "Best"
        case .hot: return "Hot"
        case .new: return "New"
        case .controversial: return "Controversial"
        case .top: return "Top"
        }
    }
    
    var icon: String {
        switch self {
        case .best: return "trophy"
        case .hot: return "flame"
        case .new: return "newspaper"
        case .controversial: return "figure.fencing"
        case .top: return "arrow.up.circle"
        }
    }
}
