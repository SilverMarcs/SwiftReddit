//
//  URLHandlingModifier.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 20/06/2025.
//

import SwiftUI

struct URLHandlingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                if let galleryImage = detectRedditImage(from: url) {
                    ImageOverlayViewModel.shared.present(images: [galleryImage])
                    return .handled
                }
                
                return .systemAction(prefersInApp: true)
            })
    }
    
    
    /// Detects if URL is a Reddit image and extracts dimensions if available
    private func detectRedditImage(from url: URL) -> GalleryImage? {
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
        
        return GalleryImage(url: urlString, dimensions: nil)
    }
}

extension View {
    /// Applies Reddit-aware URL handling to this view
    func handleURLs() -> some View {
        modifier(URLHandlingModifier())
    }
}
