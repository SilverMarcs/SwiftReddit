//
//  PostGIFView.swift
//  winston
//
//  Created for memory optimization -  GIF display
//

import SwiftUI

struct PostGIFView: View {
    @Environment(Nav.self) private var nav
  let galleryImage: GalleryImage
  
  var body: some View {
      Button {
          let linkMetadata = LinkMetadata(
            url: galleryImage.url,
            domain: galleryImage.url,
            thumbnailURL: nil
          )
          nav.path.append(linkMetadata)
      } label: {
          PostImageView(image: galleryImage)
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
