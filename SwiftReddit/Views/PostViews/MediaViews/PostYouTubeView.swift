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
      
      // Always show YouTube badge
      VStack {
        Spacer()
        HStack {
          Image(systemName: "play.rectangle.fill")
            .font(.caption)
          Text("YouTube")
            .font(.caption)
            .fontWeight(.medium)
          Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.red.opacity(0.8))
        .cornerRadius(4)
        .padding(8)
      }
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
