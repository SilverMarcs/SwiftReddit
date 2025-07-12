//
//  PostImageView.swift
//  winston
//
//  Created for memory optimization -  image display
//

import SwiftUI

struct PostImageView: View {
    var image: GalleryImage
    
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    
    var body: some View {
        if let url = URL(string: image.url) {
            ImageView(url: url, aspectRatio: image.aspectRatio)
                .matchedGeometryEffect(id: image.url, in: imageNS ?? fallbackNS)
//                .transition(.scale(scale: 1))
                .cornerRadius(12)
                .clipped()
                .onTapGesture {
                    ImageOverlayViewModel.shared.present(images: [image])
                }
        }
    }
}

#Preview {
    PostImageView(
        image: .init(url: "https://example.com/image.jpg", dimensions: CGSize(width: 800, height: 600))
    )
    .padding()
}
