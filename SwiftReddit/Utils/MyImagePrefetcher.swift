//
//  MyImagePrefetcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import Foundation
import Kingfisher

struct MyImagePrefetcher {
    static func prefetchImagesForPosts(_ posts: [Post]) {
        Task.detached {
            let imageURLs = await self.extractImageURLsFromPosts(posts)
            let urls = imageURLs.compactMap { URL(string: $0) }
            
            if !urls.isEmpty {
                let prefetcher = ImagePrefetcher(urls: urls)
                prefetcher.start()
            }
        }
    }
    
    static func extractImageURLsFromPosts(_ posts: [Post]) -> [String] {
        var imageURLs: [String] = []
        
        for post in posts {
            switch post.mediaType {
            case .image(let galleryImage):
                imageURLs.append(galleryImage.url)
                
            case .gallery(let images):
                imageURLs.append(contentsOf: images.map { $0.url })
                
            case .video(_, let thumbnailURL, _):
                if let thumbnailURL = thumbnailURL {
                    imageURLs.append(thumbnailURL)
                }
                
            case .youtube(_, let galleryImage):
                imageURLs.append(galleryImage.url)
                
            case .gif(let galleryImage):
                imageURLs.append(galleryImage.url)
                
            case .link(let metadata):
                if let thumbnailURL = metadata.thumbnailURL {
                    imageURLs.append(thumbnailURL)
                }
                
            case .repost(let originalPost):
                let nestedURLs = extractImageURLsFromPosts([originalPost])
                imageURLs.append(contentsOf: nestedURLs)
                
            case .none:
                break
            }
        }
        
        return imageURLs
    }
}
