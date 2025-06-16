//
//  LightweightMediaView.swift
//  winston
//
//  Created for memory optimization - lightweight media display
//

import SwiftUI

struct LightweightMediaView: View {
  let mediaType: LightweightMediaType
  let isNSFW: Bool
  
  @State private var imageLoaded = false
  @State private var imageError = false
  
  var body: some View {
      switch mediaType {
      case .none:
        EmptyView()
        
      case .image(let imageURL):
        LightweightImageView(imageURL: imageURL, isNSFW: isNSFW)
        
      case .gallery(let count, let imageURL):
        LightweightGalleryView(count: count, imageURL: imageURL, isNSFW: isNSFW)
        
      case .video(let thumbnailURL):
        LightweightVideoView(thumbnailURL: thumbnailURL, isNSFW: isNSFW)
        
      case .youtube(let thumbnailURL):
        LightweightYouTubeView(thumbnailURL: thumbnailURL, isNSFW: isNSFW)
        
      case .gif(let imageURL):
//        LightweightGIFView(imageURL: imageURL, isNSFW: isNSFW)
          EmptyView() // Placeholder for GIF view, not implemented yet
        
      case .link(let thumbnailURL):
        LightweightLinkView(thumbnailURL: thumbnailURL, isNSFW: isNSFW)
      }
    }
}

#Preview {
  VStack(spacing: 16) {
    LightweightMediaView(mediaType: .image(imageURL: "https://example.com/image.jpg"), isNSFW: false)
    LightweightMediaView(mediaType: .gallery(count: 5, imageURL: "https://example.com/image.jpg"), isNSFW: false)
    LightweightMediaView(mediaType: .video(thumbnailURL: "https://example.com/thumb.jpg"), isNSFW: false)
    LightweightMediaView(mediaType: .youtube(thumbnailURL: nil), isNSFW: false)
    LightweightMediaView(mediaType: .link(thumbnailURL: nil), isNSFW: false)
  }
  .padding()
}
