//
//  PostGIFView.swift
//  winston
//
//  Created for memory optimization -  GIF display
//

import SwiftUI

struct PostGIFView: View {
  let galleryImage: GalleryImage
  
  var body: some View {
      ZStack(alignment: .bottomTrailing) {
        PostImageView(image: galleryImage)
      
          Text("GIF")
              .font(.caption2)
              .fontWeight(.bold)
              .foregroundStyle(.white)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(.black.secondary, in: .rect(cornerRadius: 5))
              .padding(10)
    }
  }
}
