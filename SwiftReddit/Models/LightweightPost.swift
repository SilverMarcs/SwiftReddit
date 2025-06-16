import Foundation

/// A lightweight post model for efficient feed display
struct LightweightPost: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let score: Int
    let numComments: Int
    let created: Date
    let subreddit: String
    let url: String?
    let selftext: String?
    let mediaType: LightweightMediaType
    let thumbnail: String?
    let preview: String?
    let isNSFW: Bool
    let stickied: Bool
    let locked: Bool
    
    init(from json: [String: Any]) {
        let data = json["data"] as? [String: Any] ?? [:]
        
        self.id = data["id"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.author = data["author"] as? String ?? ""
        self.score = data["score"] as? Int ?? 0
        self.numComments = data["num_comments"] as? Int ?? 0
        self.subreddit = data["subreddit"] as? String ?? ""
        self.url = data["url"] as? String
        self.selftext = data["selftext"] as? String
        self.thumbnail = data["thumbnail"] as? String
        self.isNSFW = data["over_18"] as? Bool ?? false
        self.stickied = data["stickied"] as? Bool ?? false
        self.locked = data["locked"] as? Bool ?? false
        
        // Create date from unix timestamp
        if let createdUTC = data["created_utc"] as? Double {
            self.created = Date(timeIntervalSince1970: createdUTC)
        } else {
            self.created = Date()
        }
        
        // Extract media information
        let extractedMedia = Self.extractMediaInfo(from: data)
        self.mediaType = extractedMedia.type
        self.preview = extractedMedia.preview
    }
    
    private static func extractMediaInfo(from data: [String: Any]) -> (type: LightweightMediaType, preview: String?) {
        // Check if it's a video
        if let secureMedia = data["secure_media"] as? [String: Any],
           let redditVideo = secureMedia["reddit_video"] as? [String: Any] {
            let fallbackUrl = redditVideo["fallback_url"] as? String
            return (.video(url: fallbackUrl), nil)
        }
        
        // Check for images in preview
        if let preview = data["preview"] as? [String: Any],
           let images = preview["images"] as? [[String: Any]],
           let firstImage = images.first,
           let source = firstImage["source"] as? [String: Any],
           let imageUrl = source["url"] as? String {
            let decodedUrl = imageUrl.replacingOccurrences(of: "&amp;", with: "&")
            return (.image(url: decodedUrl), decodedUrl)
        }
        
        // Check for external links
        if let url = data["url"] as? String,
           !url.isEmpty,
           let urlObj = URL(string: url) {
            
            // Check if it's an image URL
            let imageExtensions = ["jpg", "jpeg", "png", "gif", "webp"]
            if imageExtensions.contains(urlObj.pathExtension.lowercased()) {
                return (.image(url: url), url)
            }
            
            // Check for common video/gif services
            let host = urlObj.host?.lowercased() ?? ""
            if host.contains("youtube") || host.contains("youtu.be") {
                return (.youtube(url: url), nil)
            } else if host.contains("gfycat") {
                return (.gif(url: url), nil)
            } else if url.lowercased().hasSuffix(".gif") {
                return (.gif(url: url), url)
            }
            
            return (.link(url: url), nil)
        }
        
        // Check for self text
        if let selftext = data["selftext"] as? String, !selftext.isEmpty {
            return (.text, nil)
        }
        
        return (.none, nil)
    }
}

// MARK: - Hashable
extension LightweightPost {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LightweightPost, rhs: LightweightPost) -> Bool {
        lhs.id == rhs.id
    }
}
