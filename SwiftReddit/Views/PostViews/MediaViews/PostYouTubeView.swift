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
            
            // Centered play button
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 50)) // Larger size for better visibility
                .foregroundStyle(.white, .red)
                .shadow(radius: 3) // Optional: adds subtle shadow for better contrast
        }
        .onTapGesture {
            // TODO: Handle YouTube video playback with videoID
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
