//
//  LightweightMediaView.swift
//  winston
//
//  Created for memory optimization - lightweight media display
//

import SwiftUI

struct LightweightMediaView: View {
  let mediaType: LightweightMediaType
  
  @State private var imageLoaded = false
  @State private var imageError = false
  
  var body: some View {
      switch mediaType {
      case .none:
        EmptyView()
        
      case .image(let imageURL):
        LightweightImageView(imageURL: imageURL)
        
      case .gallery(let count, let imageURL):
        LightweightGalleryView(count: count, imageURL: imageURL)
        
      case .video(let thumbnailURL):
        LightweightVideoView(thumbnailURL: thumbnailURL)
        
      case .youtube(let thumbnailURL):
        LightweightYouTubeView(thumbnailURL: thumbnailURL)
        
      case .gif(let imageURL):
        LightweightGIFView(imageURL: imageURL)
        
      case .link(let thumbnailURL):
        LightweightLinkView(thumbnailURL: thumbnailURL)
      }
    }
}

#Preview {
  VStack(spacing: 16) {
    LightweightMediaView(mediaType: .image(imageURL: "https://example.com/image.jpg"))
    LightweightMediaView(mediaType: .gallery(count: 5, imageURL: "https://example.com/image.jpg"))
    LightweightMediaView(mediaType: .video(thumbnailURL: "https://example.com/thumb.jpg"))
    LightweightMediaView(mediaType: .youtube(thumbnailURL: nil))
    LightweightMediaView(mediaType: .link(thumbnailURL: nil))
  }
  .padding()
}
