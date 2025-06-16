//
//  Post.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import Foundation
import SwiftUI

///  post structure for reduced memory usage in feeds
/// Contains only essential information needed for basic post display
struct Post: Identifiable, Hashable, Equatable {
    let id: String
    let title: String
    let author: String
    let subreddit: String
    let subredditNamePrefixed: String
    let ups: Int
    let numComments: Int
    let created: Double
    let permalink: String
    let fullname: String
    let url: String?
    let domain: String
    let isNSFW: Bool
    let isSelf: Bool
    let thumbnail: String?
    let linkFlairText: String?
    let selftext: String
    let clicked: Bool
    let saved: Bool
    let hidden: Bool
    let gilded: Int
    let downs: Int
    let hideScore: Bool
    let quarantine: Bool
    let upvoteRatio: Double
    let subredditType: String
    let totalAwardsReceived: Int
    let allowLiveComments: Bool
    let isRobotIndexable: Bool
    let sendReplies: Bool
    let contestMode: Bool
    let subredditSubscribers: Int
    let createdUTC: Double?
    let numCrossposts: Int
    let postHint: String?
    let linkFlairTextColor: String?
    let whitelistStatus: String?
    let linkFlairBackgroundColor: String?
    let linkFlairType: String?
    let approvedAtUTC: Int?
    let modReasonTitle: String?
    let topAwardedType: String?
    let authorFlairBackgroundColor: String?
    let approvedBy: String?
    let isCreatedFromAdsUI: Bool?
    let authorPremium: Bool?
    let authorFlairCSSClass: String?
    let authorFlairType: String?
    let likes: Bool?
    let stickied: Bool?
    let suggestedSort: String?
    let bannedAtUTC: String?
    let viewCount: String?
    let archived: Bool?
    let noFollow: Bool?
    let isCrosspostable: Bool?
    let pinned: Bool?
    let over18: Bool?
    let mediaOnly: Bool?
    let canGild: Bool?
    let spoiler: Bool?
    let locked: Bool?
    let treatmentTags: [String]?
    let visited: Bool?
    let removedBy: String?
    let numReports: Int?
    let distinguished: String?
    let subredditID: String?
    let authorIsBlocked: Bool?
    let modReasonBy: String?
    let removalReason: String?
    let reportReasons: [String]?
    let discussionType: String?
    let isVideo: Bool?
    let isGallery: Bool?
    let winstonSeen: Bool?
    let winstonHidden: Bool?
    
    //  media properties
    let mediaType: MediaType
    
    // Custom hash implementation to handle optionals
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    
    // custom identifiable conformance
    var identifier: String {
        return id
    }
    
    init(from postData: PostData) {
        self.id = postData.id
        self.title = postData.title
        self.author = postData.author
        self.subreddit = postData.subreddit
        self.subredditNamePrefixed = postData.subreddit_name_prefixed
        self.ups = postData.ups
        self.numComments = postData.num_comments
        self.created = postData.created
        self.permalink = postData.permalink
        self.fullname = postData.name
        self.url = postData.url.isEmpty ? nil : postData.url
        self.domain = postData.domain
        self.isNSFW = postData.over_18 ?? false
        self.isSelf = postData.is_self
        self.thumbnail = postData.thumbnail
        self.linkFlairText = postData.link_flair_text
        self.selftext = postData.selftext
        self.clicked = postData.clicked
        self.saved = postData.saved
        self.hidden = postData.hidden
        self.gilded = postData.gilded
        self.downs = postData.downs
        self.hideScore = postData.hide_score
        self.quarantine = postData.quarantine
        self.upvoteRatio = postData.upvote_ratio
        self.subredditType = postData.subreddit_type
        self.totalAwardsReceived = postData.total_awards_received
        self.allowLiveComments = postData.allow_live_comments
        self.isRobotIndexable = postData.is_robot_indexable
        self.sendReplies = postData.send_replies
        self.contestMode = postData.contest_mode
        self.subredditSubscribers = postData.subreddit_subscribers
        self.createdUTC = postData.created_utc
        self.numCrossposts = postData.num_crossposts
        self.postHint = postData.post_hint
        self.linkFlairTextColor = postData.link_flair_text_color
        self.whitelistStatus = postData.whitelist_status
        self.linkFlairBackgroundColor = postData.link_flair_background_color
        self.linkFlairType = postData.link_flair_type
        self.approvedAtUTC = postData.approved_at_utc
        self.modReasonTitle = postData.mod_reason_title
        self.topAwardedType = postData.top_awarded_type
        self.authorFlairBackgroundColor = postData.author_flair_background_color
        self.approvedBy = postData.approved_by
        self.isCreatedFromAdsUI = postData.is_created_from_ads_ui
        self.authorPremium = postData.author_premium
        self.authorFlairCSSClass = postData.author_flair_css_class
        self.authorFlairType = postData.author_flair_type
        self.likes = postData.likes
        self.stickied = postData.stickied
        self.suggestedSort = postData.suggested_sort
        self.bannedAtUTC = postData.banned_at_utc
        self.viewCount = postData.view_count
        self.archived = postData.archived
        self.noFollow = postData.no_follow
        self.isCrosspostable = postData.is_crosspostable
        self.pinned = postData.pinned
        self.over18 = postData.over_18
        self.mediaOnly = postData.media_only
        self.canGild = postData.can_gild
        self.spoiler = postData.spoiler
        self.locked = postData.locked
        self.treatmentTags = postData.treatment_tags
        self.visited = postData.visited
        self.removedBy = postData.removed_by
        self.numReports = postData.num_reports
        self.distinguished = postData.distinguished
        self.subredditID = postData.subreddit_id
        self.authorIsBlocked = postData.author_is_blocked
        self.modReasonBy = postData.mod_reason_by
        self.removalReason = postData.removal_reason
        self.reportReasons = postData.report_reasons
        self.discussionType = postData.discussion_type
        self.isVideo = postData.is_video ?? false
        self.isGallery = postData.is_gallery ?? false
        self.winstonSeen = postData.winstonSeen ?? false
        self.winstonHidden = postData.winstonHidden ?? false
        
        // Extract media information with high-quality image support
        self.mediaType = Self.extractMedia(from: postData)
    }
    
    ///  media extraction that determines media type without heavy processing
    private static func extractMedia(from data: PostData) -> MediaType {
        // Skip self posts
        guard !data.is_self else { return .none }
        
        let url = data.url
        let domain = data.domain
        
        // Get proper image URL from preview if available, fallback to thumbnail
        let imageURL = extractImageURL(from: data)
        
        // Gallery detection
        if let isGallery = data.is_gallery, isGallery {
            let galleryImageURL = extractGalleryImageURL(from: data) ?? extractImageURL(from: data)
            let count = data.gallery_data?.items?.count ?? 0
            return .gallery(count: count, imageURL: galleryImageURL)
        }
        
        // Video detection
        if data.is_video == true {
            let videoThumbnail = extractVideoThumbnail(from: data) ?? imageURL
            return .video(thumbnailURL: videoThumbnail)
        }
        
        // YouTube detection
        if domain.contains("youtube.com") || domain.contains("youtu.be") {
            let ytThumbnail = extractYouTubeThumbnail(from: data) ?? imageURL
            return .youtube(thumbnailURL: ytThumbnail)
        }
        
        // GIF detection (simple URL-based)
        if url.hasSuffix(".gif") || domain.contains("gfycat") || domain.contains("imgur") && url.contains("/gif") {
            return .gif(imageURL: imageURL)
        }
        
        // Image detection
        if url.hasSuffix(".jpg") || url.hasSuffix(".jpeg") || url.hasSuffix(".png") || url.hasSuffix(".webp") ||
           domain.contains("i.redd.it") || domain.contains("i.imgur.com") {
            return .image(imageURL: imageURL)
        }
        
        // Link with potential preview
        if !url.isEmpty && url != data.permalink {
            return .link(thumbnailURL: imageURL)
        }
        
        return .none
    }
    
    /// Extract proper image URL from PostData
    private static func extractImageURL(from data: PostData) -> String? {
        // Priority 1: High-quality preview image
        if let preview = data.preview,
           let images = preview.images,
           !images.isEmpty,
           let source = images[0].source,
           let url = source.url {
            // Convert preview URL to high-quality i.redd.it URL
            let cleanURL = url
                .replacingOccurrences(of: "/preview.", with: "/i.")
                .replacingOccurrences(of: "&amp;", with: "&")
            
            // Skip external preview URLs as they're often low quality
            if !cleanURL.contains("external-preview") {
                return cleanURL
            }
        }
        
        // Priority 2: Direct image URLs (i.redd.it, i.imgur.com, etc.)
        let url = data.url
        if url.contains("i.redd.it") || url.contains("i.imgur.com") ||
           url.hasSuffix(".jpg") || url.hasSuffix(".jpeg") || 
           url.hasSuffix(".png") || url.hasSuffix(".webp") {
            return url
        }
        
        // Priority 3: Fallback to thumbnail if available and not default
        let thumbnail = data.thumbnail
        if let thumbnail = thumbnail,
           thumbnail != "self" &&
           thumbnail != "default" &&
           thumbnail != "nsfw" &&
           !thumbnail.isEmpty {
            return thumbnail
        }
        
        return nil
    }
    
    /// Extract high-quality image URL from gallery data
    private static func extractGalleryImageURL(from data: PostData) -> String? {
        // Try to get the first gallery image in high quality
        if let galleryData = data.gallery_data?.items,
           let metadata = data.media_metadata,
           let firstItem = galleryData.first {
            let mediaId = firstItem.media_id
            if let itemMeta = metadata[mediaId],
               let extArray = itemMeta?.m?.split(separator: "/"),
               let ext = extArray.last {
                return "https://i.redd.it/\(mediaId).\(ext)"
            }
        }
        return nil
    }
    
    /// Extract video thumbnail from preview or media data
    private static func extractVideoThumbnail(from data: PostData) -> String? {
        // Try to get thumbnail from reddit video preview
        if let preview = data.preview,
           let videoPreview = preview.reddit_video_preview,
           let scrubberURL = videoPreview.scrubber_media_url {
            return scrubberURL
        }
        
        // Try to get thumbnail from reddit video media
        if let media = data.media,
           let redditVideo = media.reddit_video,
           let scrubberURL = redditVideo.scrubber_media_url {
            return scrubberURL
        }
        
        return nil
    }
    
    /// Extract YouTube thumbnail from media oembed data
    private static func extractYouTubeThumbnail(from data: PostData) -> String? {
        // Try to get high-quality thumbnail from oembed
        if let media = data.media,
           let oembed = media.oembed,
           let thumbnailURL = oembed.thumbnail_url {
            return thumbnailURL
        }
        
        return nil
    }
    
    /// Basic relative time string for display
    var timeAgo: String {
        let timeInterval = Date().timeIntervalSince1970 - created
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
    
    /// Format vote count for display
    var formattedUps: String {
        if ups >= 1000 {
            return String(format: "%.1fk", Double(ups) / 1000.0)
        }
        return String(ups)
    }
    
    /// Format comment count for display
    var formattedComments: String {
        if numComments >= 1000 {
            return String(format: "%.1fk", Double(numComments) / 1000.0)
        }
        return String(numComments)
    }
    
    /// Get flair background color from Reddit API
    var flairBackgroundColor: Color {
        guard let bgColor = linkFlairBackgroundColor, !bgColor.isEmpty else {
            return Color(hex: "D5D7D9") // Default light gray
        }
        return Color(hex: bgColor)
    }
    
    /// Get flair text color from Reddit API
    var flairTextColor: Color {
        let hasBackground = linkFlairBackgroundColor != nil && !linkFlairBackgroundColor!.isEmpty
        
        if hasBackground, let textColor = linkFlairTextColor {
            return textColor == "light" ? .white : .black
        }
        
        return .black // Default
    }
}
