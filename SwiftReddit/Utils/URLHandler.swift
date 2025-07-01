//
//  URLHandler.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 20/06/2025.
//

import Foundation
import SwiftUI

struct URLHandler {
    /// Handles URL navigation, detecting Reddit images and routing accordingly
    static func handleURL(_ url: URL, nav: Nav) -> OpenURLAction.Result {
        // Check if this is a Reddit image URL
        if let galleryImage = detectRedditImage(from: url) {
            let imageModalData = ImageModalData(image: galleryImage)
            nav.path.append(imageModalData)
        } else {
            // Handle as regular link
            let linkMetadata = LinkMetadata(
                url: url.absoluteString,
                domain: url.host ?? "Unknown",
                thumbnailURL: nil
            )
            nav.path.append(linkMetadata)
        }
        
        return .handled
    }
    
    /// Detects if URL is a Reddit image and extracts dimensions if available
    private static func detectRedditImage(from url: URL) -> GalleryImage? {
        let urlString = url.absoluteString
        
        // Check if URL matches Reddit image patterns
        let redditImagePatterns = [
            "preview.redd.it",
            "i.redd.it",
            "i.imgur.com"
        ]
        
        let isRedditImage = redditImagePatterns.contains { pattern in
            urlString.contains(pattern)
        }
        
        guard isRedditImage else { return nil }
        
        // Extract dimensions from URL query parameters if available
        let dimensions = extractDimensionsFromURL(url)
        
        return GalleryImage(url: urlString, dimensions: dimensions)
    }
    
    /// Extracts width and height from URL query parameters
    private static func extractDimensionsFromURL(_ url: URL) -> CGSize? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var width: CGFloat?
        var height: CGFloat?
        
        for item in queryItems {
            switch item.name.lowercased() {
            case "width", "w":
                if let value = item.value, let w = Double(value) {
                    width = CGFloat(w)
                }
            case "height", "h":
                if let value = item.value, let h = Double(value) {
                    height = CGFloat(h)
                }
            default:
                break
            }
        }
        
        if let width = width, let height = height {
            return CGSize(width: width, height: height)
        }
        
        return nil
    }
}
