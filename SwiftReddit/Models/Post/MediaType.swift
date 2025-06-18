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

indirect enum MediaType: Hashable {
    case none
    case image(imageURL: String?, dimensions: CGSize?)
    case gallery(images: [GalleryImage])
    case video(videoURL: String?, thumbnailURL: String?, dimensions: CGSize?)
    case youtube(videoID: String, thumbnailURL: String?, dimensions: CGSize?)
    case link(metadata: LinkMetadata)
    case gif(imageURL: String?, dimensions: CGSize?)
    case repost(originalPost: Post)
    
    var hasMedia: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
}
