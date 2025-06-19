//
//  PostImageView.swift
//  winston
//
//  Created for memory optimization -  image display
//

import SwiftUI

struct PostImageView: View {
    var image: GalleryImage
    
    @State private var showFullscreen = false
    
    var body: some View {
        if let url = URL(string: image.url) {
            Button {
                showFullscreen = true
            } label: {
                CachedAsyncImage(url: url, aspectRatio: aspectRatio)
                    .frame(maxHeight: 500)
                    .cornerRadius(12)
                    .clipped()
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showFullscreen) {
                ImageViewer(image: image)
            }
        }
    }
    
    private var aspectRatio: CGFloat {
        let dimensions = image.dimensions
            guard
              dimensions.width > 0 && dimensions.height > 0 else {
            return 16/9 // Default aspect ratio
        }
        return dimensions.width / dimensions.height
    }
}

#Preview {
    PostImageView(
        image: .init(url: "https://example.com/image.jpg", dimensions: CGSize(width: 800, height: 600))
    )
    .padding()
}
