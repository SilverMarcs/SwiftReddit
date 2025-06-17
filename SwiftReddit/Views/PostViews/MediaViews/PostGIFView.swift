//
//  PostGIFView.swift
//  winston
//
//  Created for memory optimization -  GIF display
//

import SwiftUI

struct PostGIFView: View {
  let imageURL: String?
  let dimensions: CGSize?
  
  var body: some View {
    ZStack {
        PostImageView(imageURL: imageURL, dimensions: dimensions)
      
      // Always show GIF badge
      VStack {
        Spacer()
        HStack {
          Image(systemName: "livephoto")
            .font(.caption)
          Text("GIF")
            .font(.caption)
            .fontWeight(.medium)
          Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.8))
        .cornerRadius(4)
        .padding(8)
      }
    }
  }
}
