//
//  PostYouTubeView.swift
//  winston
//
//  Created for memory optimization -  YouTube display
//

import SwiftUI

struct PostYouTubeView: View {
    @Environment(\.openURL) var openURL
    
    let videoID: String
    let galleryImage: GalleryImage

    var body: some View {
        Button {
            if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                openURL(url)
            }
        } label: {
            PostImageView(image: galleryImage)
                .disabled(true)
                .overlay(alignment: .center) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white, .red)
                        .shadow(radius: 3)
                }
        }
        .buttonStyle(.plain)
    }
}
