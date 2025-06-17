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
    
    // Subreddit details
    let subredditIconURL: String?
    
    //  media properties
    let mediaType: MediaType
    
    // Custom hash implementation to handle optionals
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
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
        
        // Extract subreddit icon URL
        self.subredditIconURL = Self.extractSubredditIcon(from: postData)
        
        // Extract media information with high-quality image support
        self.mediaType = Self.extractMedia(from: postData)
    }
    
    ///  media extraction that determines media type with high-quality URLs and dimensions
    private static func extractMedia(from data: PostData) -> MediaType {
        // Skip self posts
        guard !data.is_self else { return .none }
        
        let url = data.url
        let domain = data.domain
        
        // PRIORITY 1: Gallery detection (store all high-quality images)
        if let isGallery = data.is_gallery, isGallery,
           let galleryData = data.gallery_data?.items, 
           let metadata = data.media_metadata {
            
            let galleryImages = extractAllGalleryImages(from: galleryData, metadata: metadata)
            
            if !galleryImages.isEmpty {
                return .gallery(images: galleryImages)
            }
        }
        
        // PRIORITY 2: Reddit Video (HLS for high quality)
        if let videoPreview = data.preview?.reddit_video_preview,
           let hlsURL = videoPreview.hls_url,
           let width = videoPreview.width,
           let height = videoPreview.height {
            
            let thumbnailURL = videoPreview.scrubber_media_url ?? extractImageURL(from: data)
            return .video(
                videoURL: hlsURL,
                thumbnailURL: thumbnailURL,
                dimensions: CGSize(width: width, height: height)
            )
        }
        
        if let redditVideo = data.media?.reddit_video,
           let hlsURL = redditVideo.hls_url,
           let width = redditVideo.width,
           let height = redditVideo.height {
            
            let thumbnailURL = redditVideo.scrubber_media_url ?? extractImageURL(from: data)
            return .video(
                videoURL: hlsURL,
                thumbnailURL: thumbnailURL,
                dimensions: CGSize(width: width, height: height)
            )
        }
        
        // PRIORITY 3: YouTube Videos
        if domain.contains("youtube.com") || domain.contains("youtu.be") {
            if let oembed = data.media?.oembed,
               let html = oembed.html,
               let videoID = extractYouTubeID(from: html),
               let width = oembed.width,
               let height = oembed.height {
                
                let thumbnailURL = oembed.thumbnail_url ?? extractImageURL(from: data)
                return .youtube(
                    videoID: videoID,
                    thumbnailURL: thumbnailURL,
                    dimensions: CGSize(width: width, height: height)
                )
            }
            
            // Fallback for YouTube URLs without oembed
            if let videoID = extractYouTubeIDFromURL(url) {
                let thumbnailURL = "https://img.youtube.com/vi/\(videoID)/maxresdefault.jpg"
                return .youtube(
                    videoID: videoID,
                    thumbnailURL: thumbnailURL,
                    dimensions: nil
                )
            }
        }
        
        // PRIORITY 4: Direct video files
        let videoFormats = [".mov", ".mp4", ".avi", ".mkv", ".flv", ".wmv", ".mpg", ".mpeg", ".webm"]
        if videoFormats.contains(where: { url.hasSuffix($0) }) {
            let thumbnailURL = extractImageURL(from: data)
            return .video(
                videoURL: url,
                thumbnailURL: thumbnailURL,
                dimensions: nil
            )
        }
        
        // PRIORITY 5: GIF detection (including animated) - improved detection
        if url.hasSuffix(".gif") || 
           url.hasSuffix(".gifv") ||
           domain.contains("gfycat") || 
           domain.contains("redgifs") ||
           (domain.contains("imgur") && (url.contains("gif") || url.contains("gifv"))) {
            let (imageURL, dimensions) = extractHighQualityImageWithDimensions(from: data)
            return .gif(imageURL: imageURL, dimensions: dimensions)
        }
        
        // PRIORITY 6: Direct image formats
        let imageFormats = [".gif", ".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tiff", ".svg", ".ico", ".heic", ".heif"]
        if imageFormats.contains(where: { url.hasSuffix($0) }) || 
           domain.contains("i.redd.it") || domain.contains("i.imgur.com") {
            let (imageURL, dimensions) = extractHighQualityImageWithDimensions(from: data)
            return .image(imageURL: imageURL, dimensions: dimensions)
        }
        
        // PRIORITY 7: Preview images (high quality conversion) - Better detection
        if let preview = data.preview,
           let images = preview.images,
           !images.isEmpty {
            let (imageURL, dimensions) = extractHighQualityImageWithDimensions(from: data)
            if let imageURL = imageURL {
                // Check if this is actually an image or just a link preview
                let imageFormats = [".gif", ".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tiff", ".svg", ".ico", ".heic", ".heif"]
                let isDirectImage = imageFormats.contains(where: { url.hasSuffix($0) }) || 
                                  url.contains("i.redd.it") || url.contains("i.imgur.com")
                
                if isDirectImage {
                    return .image(imageURL: imageURL, dimensions: dimensions)
                }
            }
        }
        
        // PRIORITY 8: External links with rich metadata - extract from any domain
        if !url.isEmpty && url != data.permalink && !data.is_self {
            let linkMetadata = extractLinkMetadata(from: data)
            
            // Create link for any external URL - no domain restrictions
            return .link(metadata: linkMetadata)
        }
        
        return .none
    }
    
    /// Extract high-quality image URL with dimensions from PostData
    private static func extractHighQualityImageWithDimensions(from data: PostData) -> (url: String?, dimensions: CGSize?) {
        var imageURL: String? = nil
        var dimensions: CGSize? = nil
        
        // Priority 1: High-quality preview image with dimensions
        if let preview = data.preview,
           let images = preview.images,
           !images.isEmpty,
           let source = images[0].source,
           let url = source.url,
           let width = source.width,
           let height = source.height {
            
            // Convert preview URL to high-quality i.redd.it URL
            let cleanURL = url
                .replacingOccurrences(of: "/preview.", with: "/i.")
                .replacingOccurrences(of: "&amp;", with: "&")
            
            // Skip external preview URLs as they're often low quality
            if !cleanURL.contains("external-preview") {
                imageURL = cleanURL
                dimensions = CGSize(width: width, height: height)
            }
        }
        
        // Priority 2: Direct image URLs (i.redd.it, i.imgur.com, etc.)
        if imageURL == nil {
            let url = data.url
            if url.contains("i.redd.it") || url.contains("i.imgur.com") ||
               url.hasSuffix(".jpg") || url.hasSuffix(".jpeg") || 
               url.hasSuffix(".png") || url.hasSuffix(".webp") ||
               url.hasSuffix(".gif") {
                imageURL = url
                // Try to get dimensions from preview if available
                if let preview = data.preview,
                   let images = preview.images,
                   !images.isEmpty,
                   let source = images[0].source,
                   let width = source.width,
                   let height = source.height {
                    dimensions = CGSize(width: width, height: height)
                }
            }
        }
        
        // Priority 3: Fallback to thumbnail if available and decent quality
        if imageURL == nil {
            let thumbnail = data.thumbnail
            if let thumbnail = thumbnail,
               thumbnail != "self" &&
               thumbnail != "default" &&
               thumbnail != "nsfw" &&
               thumbnail != "" &&
               thumbnail.starts(with: "http") &&
               !thumbnail.contains("b.thumbs.redditmedia.com") { // Skip low-quality thumbnails
                imageURL = thumbnail
            }
        }
        
        return (imageURL, dimensions)
    }
    
    /// Extract all gallery images with high-quality URLs and dimensions
    private static func extractAllGalleryImages(from galleryData: [GalleryDataItem], metadata: [String: MediaMetadataItem?]) -> [GalleryImage] {
        return galleryData.compactMap { item in
            let mediaId = item.media_id
            if let itemMeta = metadata[mediaId],
               let extArray = itemMeta?.m?.split(separator: "/"),
               let ext = extArray.last,
               let size = itemMeta?.s {
                
                let url = "https://i.redd.it/\(mediaId).\(ext)"
                let dimensions = CGSize(width: size.x, height: size.y)
                return GalleryImage(url: url, dimensions: dimensions)
            }
            return nil
        }
    }
    
    /// Extract best quality thumbnail URL for links
    private static func extractBestThumbnailURL(from data: PostData) -> String? {
        // Priority 1: High-quality preview thumbnail (but not external-preview)
        if let preview = data.preview,
           let images = preview.images,
           !images.isEmpty,
           let source = images[0].source,
           let url = source.url {
            
            let cleanURL = url
                .replacingOccurrences(of: "/preview.", with: "/i.")
                .replacingOccurrences(of: "&amp;", with: "&")
            
            // Accept even external previews for links if they're decent quality
            if !cleanURL.contains("external-preview") || cleanURL.contains("format=") {
                return cleanURL
            }
        }
        
        // Priority 2: Regular thumbnail if it's not a default/placeholder
        let thumbnail = data.thumbnail
        if let thumbnail = thumbnail,
           thumbnail != "self" &&
           thumbnail != "default" &&
           thumbnail != "nsfw" &&
           thumbnail != "" &&
           thumbnail.starts(with: "http") {
            return thumbnail
        }
        
        return nil
    }
    
    /// Extract YouTube video ID from oembed HTML
    private static func extractYouTubeID(from html: String) -> String? {
        let pattern = "(?<=www\\.youtube\\.com/embed/)[^?]*"
        let regex = try? NSRegularExpression(pattern: pattern)
        return regex?.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)).map {
            String(html[Range($0.range, in: html)!])
        }
    }
    
    /// Extract YouTube video ID from URL patterns
    private static func extractYouTubeIDFromURL(_ url: String) -> String? {
        let patterns = [
            "(?<=watch\\?v=)[^&]*",           // youtube.com/watch?v=VIDEO_ID
            "(?<=youtu\\.be/)[^?]*",         // youtu.be/VIDEO_ID
            "(?<=embed/)[^?]*"               // youtube.com/embed/VIDEO_ID
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.count)) {
                return String(url[Range(match.range, in: url)!])
            }
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
    
    /// Extract basic image URL from PostData (for backward compatibility)
    private static func extractImageURL(from data: PostData) -> String? {
        let (url, _) = extractHighQualityImageWithDimensions(from: data)
        return url
    }
    
    /// Get high-quality image URL for the post
    var highQualityImageURL: String? {
        return mediaType.imageURL
    }
    
    /// Get video URL for direct playback (HLS preferred)
    var videoPlaybackURL: String? {
        return mediaType.videoURL
    }
    
    /// Get YouTube video ID for embedding
    var youtubeVideoID: String? {
        return mediaType.youtubeVideoID
    }
    
    /// Get media dimensions for proper aspect ratio
    var mediaDimensions: CGSize? {
        return mediaType.dimensions
    }
    
    /// Check if post has high-quality video content
    var hasHighQualityVideo: Bool {
        switch mediaType {
        case .video(let videoURL, _, _):
            return videoURL?.contains("hls_url") == true || videoURL != nil
        case .youtube:
            return true
        default:
            return false
        }
    }
    
//    /// Check if post is a gallery with multiple images
//    var isGallery: Bool {
//        if case .gallery = mediaType {
//            return true
//        }
//        return false
//    }
//    
    /// Get gallery count
    var galleryImageCount: Int {
        return mediaType.galleryCount
    }
    
    /// Get all gallery images
    var galleryImages: [GalleryImage] {
        return mediaType.galleryImages
    }
    
    /// Extract rich link metadata from PostData
    private static func extractLinkMetadata(from data: PostData) -> LinkMetadata {
        let url = data.url
        let domain = data.domain
        
        // Get the best available thumbnail
        let thumbnailURL = extractBestThumbnailURL(from: data)
        
        return LinkMetadata(
            url: url,
            domain: domain,
            thumbnailURL: thumbnailURL
        )
    }
    
    /// Get link metadata for rich link previews
    var linkMetadata: LinkMetadata? {
        return mediaType.linkMetadata
    }
    
    /// Extract subreddit icon URL from PostData
    private static func extractSubredditIcon(from data: PostData) -> String? {
        // Check if subreddit details are available
        guard let srDetail = data.sr_detail else { return nil }
        
        // Prefer community_icon over icon_img
        if let communityIcon = srDetail.community_icon, !communityIcon.isEmpty {
            // Remove query parameters from the URL for a cleaner icon
            let cleanURL = communityIcon.components(separatedBy: "?").first ?? communityIcon
            return cleanURL
        }
        
        if let iconImg = srDetail.icon_img, !iconImg.isEmpty {
            let cleanURL = iconImg.components(separatedBy: "?").first ?? iconImg
            return cleanURL
        }
        
        return nil
    }
}
