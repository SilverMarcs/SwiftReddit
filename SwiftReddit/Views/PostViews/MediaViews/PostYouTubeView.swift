//
//  PostYouTubeView.swift
//  winston
//
//  Created for memory optimization -  YouTube display
//

import SwiftUI

struct PostYouTubeView: View {
    let videoID: String
    let galleryImage: GalleryImage
    
    var body: some View {
        ZStack {
            PostImageView(image: galleryImage)
                .allowsHitTesting(false)  // This makes PostImageView ignore all touch events
            
            // Centered play button
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.white, .red)
                .shadow(radius: 3)
        }
        .contentShape(Rectangle())  // This makes the entire ZStack clickable
        .onTapGesture {
            print("Opening YouTube video: \(videoID)")
            if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                // Open in YouTube app or Safari
                #if canImport(UIKit)
                UIApplication.shared.open(url)
                #endif
            }
        }
    }
}
