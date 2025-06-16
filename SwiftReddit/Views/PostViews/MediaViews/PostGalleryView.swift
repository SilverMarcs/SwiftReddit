//
//  PostGalleryView.swift
//  winston
//
//  Created for memory optimization -  gallery display
//

import SwiftUI

struct PostGalleryView: View {
  let count: Int
  let imageURL: String?
  
  var body: some View {
    ZStack {
        PostImageView(imageURL: imageURL)
      
      VStack {
        Spacer()
        HStack {
          Spacer()
          HStack(spacing: 4) {
            Image(systemName: "rectangle.grid.3x2")
              .font(.caption)
            Text("\(count)")
              .font(.caption)
              .fontWeight(.medium)
          }
          .foregroundColor(.white)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.black.opacity(0.7))
          .cornerRadius(12)
          .padding(8)
        }
      }
    }
  }
}
