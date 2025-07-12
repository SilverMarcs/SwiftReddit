//
//  MediaType.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

struct GalleryImage: Hashable, Identifiable {
    let url: String
    let dimensions: CGSize?
    
    var id: String {
        return url
    }
    
    var aspectRatio: CGFloat? {
        guard let dimensions = dimensions else { return nil }
        return dimensions.width / dimensions.height
    }
}

struct ImageModalData: Hashable {
    let images: [GalleryImage]
    let startIndex: Int
    
    init(images: [GalleryImage], startIndex: Int) {
        self.images = images
        self.startIndex = startIndex
    }
    
    init(image: GalleryImage) {
        self.images = [image]
        self.startIndex = 0
    }
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
    case image(galleryImage: GalleryImage)
    case gallery(galleryImages: [GalleryImage])
    case video(videoURL: String?, thumbnailURL: String?, dimensions: CGSize?)
    case youtube(videoID: String, galleryImage: GalleryImage)
    case link(metadata: LinkMetadata)
    case gif(galleryImage: GalleryImage)
    case repost(originalPost: Post)
    
    var hasMedia: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
    var firstMediaURL: String? {
        switch self {
        case .image(let galleryImage):
            return galleryImage.url
        case .gallery(let images):
            return images.first?.url
        case .video(_, let thumbnailURL, _):
            return thumbnailURL
        case .youtube(_, let galleryImage):
            return galleryImage.url
        case .gif(let galleryImage):
            return galleryImage.url
        case .link(let metadata):
            return metadata.thumbnailURL
        case .none, .repost:
            return nil
        }
    }
}
