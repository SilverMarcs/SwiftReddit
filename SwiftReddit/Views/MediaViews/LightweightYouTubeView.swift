//
//  LightweightYouTubeView.swift
//  winston
//
//  Created for memory optimization - lightweight YouTube display
//

import SwiftUI

struct LightweightYouTubeView: View {
  let thumbnailURL: String?
  let isNSFW: Bool
  
  var body: some View {
    ZStack {
      LightweightImageView(imageURL: thumbnailURL, isNSFW: isNSFW)
      
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
  }
}
