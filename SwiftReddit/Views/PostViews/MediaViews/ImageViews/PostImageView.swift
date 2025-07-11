//
//  PostImageView.swift
//  winston
//
//  Created for memory optimization -  image display
//

import SwiftUI

struct PostImageView: View {
    var image: GalleryImage
    
    @Environment(\.imageZoomNamespace) private var zoomNamespace
    
    var body: some View {
        if let url = URL(string: image.url) {
            ImageView(url: url, aspectRatio: image.aspectRatio)
                .matchedGeometryEffect(id: image.url, in: zoomNamespace)
//                .transition(.scale(scale: 1))
                .cornerRadius(12)
                .clipped()
//                .frame(
//                    maxWidth: .infinity,
//                    maxHeight: 500,
//                    alignment: .center
//                )
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
