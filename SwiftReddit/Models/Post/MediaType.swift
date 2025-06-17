//
//  MediaType.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

struct GalleryImage: Hashable {
    let url: String
    let dimensions: CGSize
}

struct LinkMetadata: Hashable {
    let url: String
    let domain: String
    let thumbnailURL: String?
    
    init(url: String, domain: String, thumbnailURL: String? = nil) {
        self.url = url
        self.domain = domain
        self.thumbnailURL = thumbnailURL
    }
}

enum MediaType: Hashable {
    case none
    case image(imageURL: String?, dimensions: CGSize?)
    case gallery(images: [GalleryImage])
    case video(videoURL: String?, thumbnailURL: String?, dimensions: CGSize?)
    case youtube(videoID: String, thumbnailURL: String?, dimensions: CGSize?)
    case link(metadata: LinkMetadata)
    case gif(imageURL: String?, dimensions: CGSize?)
    
    var hasMedia: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
    var imageURL: String? {
        switch self {
        case .none: return nil
        case .image(let url, _), .gif(let url, _):
            return url
        case .gallery(let images):
            return images.first?.url
        case .video(_, let thumbnailURL, _), .youtube(_, let thumbnailURL, _):
            return thumbnailURL
        case .link(let metadata):
            return metadata.thumbnailURL
        }
    }
    
    var videoURL: String? {
        switch self {
        case .video(let videoURL, _, _):
            return videoURL
        default:
            return nil
        }
    }
    
    var youtubeVideoID: String? {
        switch self {
        case .youtube(let videoID, _, _):
            return videoID
        default:
            return nil
        }
    }
    
    var dimensions: CGSize? {
        switch self {
        case .image(_, let dimensions), .video(_, _, let dimensions), .youtube(_, _, let dimensions), .gif(_, let dimensions):
            return dimensions
        case .gallery(let images):
            return images.first?.dimensions
        default:
            return nil
        }
    }
    
    var galleryImages: [GalleryImage] {
        switch self {
        case .gallery(let images):
            return images
        default:
            return []
        }
    }
    
    var galleryCount: Int {
        switch self {
        case .gallery(let images):
            return images.count
        default:
            return 0
        }
    }
    
    var linkMetadata: LinkMetadata? {
        switch self {
        case .link(let metadata):
            return metadata
        default:
            return nil
        }
    }
}
