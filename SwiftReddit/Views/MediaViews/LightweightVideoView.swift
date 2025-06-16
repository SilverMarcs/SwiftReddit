//
//  LightweightVideoView.swift
//  winston
//
//  Created for memory optimization - lightweight video display
//

import SwiftUI

struct LightweightVideoView: View {
  let thumbnailURL: String?
  let isNSFW: Bool
  
  var body: some View {
    ZStack {
      LightweightImageView(imageURL: thumbnailURL, isNSFW: isNSFW)
      
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
  }
}
