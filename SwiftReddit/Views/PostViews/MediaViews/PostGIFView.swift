//
//  PostGIFView.swift
//  winston
//
//  Created for memory optimization -  GIF display
//

import SwiftUI

struct PostGIFView: View {
    let galleryImage: GalleryImage
    @Environment(\.openURL) var openURL
  
  var body: some View {
      Button {
          if let url = URL(string: galleryImage.url) {
              openURL(url, prefersInApp: true)
          }
      } label: {
          PostImageView(image: galleryImage)
              .disabled(true)
              .overlay(alignment: .bottomTrailing) {
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
      .buttonStyle(.plain)
  }
}
