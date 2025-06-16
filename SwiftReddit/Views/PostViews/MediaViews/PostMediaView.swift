//
//  PostMediaView.swift
//  winston
//
//  Created for memory optimization -  media display
//

import SwiftUI

struct PostMediaView: View {
  let mediaType: MediaType
  
  @State private var imageLoaded = false
  @State private var imageError = false
  
  var body: some View {
      switch mediaType {
      case .none:
        EmptyView()
        
      case .image(let imageURL):
        PostImageView(imageURL: imageURL)
        
      case .gallery(let count, let imageURL):
          PostGalleryView(count: count, imageURL: imageURL)
        
      case .video(let thumbnailURL):
          PostVideoView(thumbnailURL: thumbnailURL)
        
      case .youtube(let thumbnailURL):
          PostYouTubeView(thumbnailURL: thumbnailURL)
        
      case .gif(let imageURL):
          PostGIFView(imageURL: imageURL)
        
      case .link(let thumbnailURL):
        PostLinkView(thumbnailURL: thumbnailURL)
      }
    }
}

#Preview {
  VStack(spacing: 16) {
      PostMediaView(mediaType: .image(imageURL: "https://example.com/image.jpg"))
      PostMediaView(mediaType: .gallery(count: 5, imageURL: "https://example.com/image.jpg"))
      PostMediaView(mediaType: .video(thumbnailURL: "https://example.com/thumb.jpg"))
      PostMediaView(mediaType: .youtube(thumbnailURL: nil))
      PostMediaView(mediaType: .link(thumbnailURL: nil))
  }
  .padding()
}
