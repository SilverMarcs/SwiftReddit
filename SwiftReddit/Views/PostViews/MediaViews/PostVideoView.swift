//
//  PostVideoView.swift
//  winston
//
//  Created for memory optimization -  video display
//

import SwiftUI

struct PostVideoView: View {
  let videoURL: String?
  let thumbnailURL: String?
  let dimensions: CGSize?
  
  var body: some View {
    ZStack {
        PostImageView(imageURL: thumbnailURL, dimensions: dimensions)
      
      // Play button overlay - always show
      Circle()
        .fill(Color.black.opacity(0.7))
        .frame(width: 50, height: 50)
        .overlay(
          Image(systemName: "play.fill")
            .font(.title2)
            .foregroundColor(.white)
            .offset(x: 2) // Slight offset to center visually
        )
    }
    .onTapGesture {
      // TODO: Handle video playback with videoURL
      if let videoURL = videoURL {
        print("Playing video: \(videoURL)")
      }
    }
  }
}
