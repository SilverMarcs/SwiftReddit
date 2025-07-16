//
//  PostImageView.swift
//  winston
//
//  Created for memory optimization -  image display
//

import SwiftUI
import CachedAsyncImage

struct PostImageView: View {
    @Environment(\.appendToPath) var appendToPath

    var image: GalleryImage
    
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    
    var body: some View {
        if let url = URL(string: image.url) {
            Button {
                appendToPath(ImageModalData(image: image))
            } label: {
                CachedAsyncImage(url: url, targetSize: CGSize(width: 500, height: 500))
                    .aspectRatio(image.aspectRatio, contentMode: .fit)
                    .matchedTransitionSource(id: image.url, in: imageNS ?? fallbackNS)
                    .cornerRadius(12)
                    .clipped()
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    PostImageView(
        image: .init(url: "https://example.com/image.jpg", dimensions: CGSize(width: 800, height: 600))
    )
    .padding()
}
