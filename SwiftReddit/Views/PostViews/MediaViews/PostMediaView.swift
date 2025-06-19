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
        
      case .image(let galleryImage):
          PostImageView(image: galleryImage)
        
      case .gallery(let images):
          PostGalleryView(images: images)
        
      case .video(let videoURL, let thumbnailURL, let dimensions):
           PostVideoView(videoURL: videoURL, thumbnailURL: thumbnailURL, dimensions: dimensions)
        
      case .youtube(let videoID, let galleryImage):
          PostYouTubeView(videoID: videoID, galleryImage: galleryImage)
        
      case .gif(let galleryImage):
          PostGIFView(galleryImage: galleryImage)
        
      case .repost(let originalPost):
          PostRepostView(originalPost: originalPost)
        
      case .link(let metadata):
        PostLinkView(metadata: metadata)
      }
    }
}

#Preview {
  NavigationStack {
    VStack(spacing: 16) {
        PostMediaView(mediaType: .image(galleryImage: GalleryImage(url: "https://example.com/image.jpg", dimensions: CGSize(width: 800, height: 600))))
        
        PostMediaView(mediaType: .gallery(images: [
          GalleryImage(url: "https://example.com/image1.jpg", dimensions: CGSize(width: 800, height: 600)),
          GalleryImage(url: "https://example.com/image2.jpg", dimensions: CGSize(width: 600, height: 800)),
          GalleryImage(url: "https://example.com/image3.jpg", dimensions: CGSize(width: 800, height: 600)),
          GalleryImage(url: "https://example.com/image4.jpg", dimensions: CGSize(width: 800, height: 600)),
          GalleryImage(url: "https://example.com/image5.jpg", dimensions: CGSize(width: 800, height: 600))
        ]))
        
        PostMediaView(mediaType: .video(videoURL: "https://example.com/video.mp4", thumbnailURL: "https://example.com/thumb.jpg", dimensions: CGSize(width: 1280, height: 720)))
        PostMediaView(mediaType: .youtube(videoID: "dQw4w9WgXcQ", galleryImage: GalleryImage(url: "https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg", dimensions: CGSize(width: 1280, height: 720))))
        PostMediaView(mediaType: .link(metadata: LinkMetadata(url: "https://developer.apple.com/swiftui", domain: "developer.apple.com", thumbnailURL: "https://example.com/thumb.jpg")))
    }
    .padding()
  }
}
