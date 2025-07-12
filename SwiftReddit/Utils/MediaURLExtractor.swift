//
//  MediaURLExtractor.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 12/07/2025.
//

import Foundation
import UIKit
import Kingfisher

/// Utility for extracting and prefetching image URLs during media processing
struct MediaURLExtractor {
    
    /// Kingfisher options for prefetching with downsampling and JPEG serialization
    static let prefetchOptions: KingfisherOptionsInfo = [
        .processor(DownsamplingImageProcessor(size: CGSize(width: 1000, height: 1000))),
        .cacheSerializer(FormatIndicatedCacheSerializer.jpeg),
        .alsoPrefetchToMemory
//        .backgroundDecode,
//        .cacheOriginalImage,
//        .scaleFactor(UIScreen.main.scale),
//        .cacheMemoryOnly // Keep in memory for faster access
//        .scaleFactor(UIScreen.main.scale),

    ]
    
    /// Extract image URLs from a MediaType and start prefetching immediately
    /// - Parameter mediaType: The MediaType to extract URLs from
    /// - Returns: Array of URLs that were extracted and queued for prefetching
    @discardableResult
    static func extractAndPrefetchURLs(from mediaType: MediaType) -> [URL] {
        return [] // TODO: come back to this
//        let urls = extractImageURLs(from: mediaType)
//        
//        if !urls.isEmpty {
//            // Prefetch immediately for individual posts
//            prefetchImages(urls: urls)
//        }
//        
//        return urls
    }
    
    /// Extract all image URLs from a MediaType
    /// - Parameter mediaType: The MediaType to extract URLs from
    /// - Returns: Array of valid URLs
    static func extractImageURLs(from mediaType: MediaType) -> [URL] {
        var urls: [URL] = []
        
        switch mediaType {
        case .image(let galleryImage):
            if let url = URL(string: galleryImage.url) {
                urls.append(url)
            }
            
        case .gallery(let images):
            for image in images {
                if let url = URL(string: image.url) {
                    urls.append(url)
                }
            }
            
        case .gif(let galleryImage):
            if let url = URL(string: galleryImage.url) {
                urls.append(url)
            }
            
        case .youtube(_, let galleryImage):
            if let url = URL(string: galleryImage.url) {
                urls.append(url)
            }
            
        case .video(_, let thumbnailURL, _):
            if let thumbnailURL = thumbnailURL,
               let url = URL(string: thumbnailURL) {
                urls.append(url)
            }
            
        case .link(let metadata):
            if let thumbnailURL = metadata.thumbnailURL,
               let url = URL(string: thumbnailURL) {
                urls.append(url)
            }
            
        case .repost(let originalPost):
            // Recursively extract URLs from the original post
            let originalURLs = extractImageURLs(from: originalPost.mediaType)
            urls.append(contentsOf: originalURLs)
            
        case .none:
            break
        }
        
        return urls
    }
    
    /// Prefetch images using Kingfisher's ImagePrefetcher
    /// - Parameter urls: URLs to prefetch
    private static func prefetchImages(urls: [URL]) {
        let prefetcher = ImagePrefetcher(
            urls: urls,
            options: prefetchOptions, completionHandler:  { skippedResources, failedResources, completedResources in
                if !failedResources.isEmpty {
                    AppLogger.info("Image prefetching completed with \(failedResources.count) failures")
                }
            })
        
        prefetcher.start()
    }
}
