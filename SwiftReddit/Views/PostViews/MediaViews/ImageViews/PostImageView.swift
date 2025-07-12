//
//  PostImageView.swift
//  winston
//
//  Created for memory optimization -  image display
//

import SwiftUI

struct PostImageView: View {
    @Environment(Nav.self) private var nav

    var image: GalleryImage
    
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    
    var body: some View {
        if let url = URL(string: image.url) {
            Button {
                nav.path.append(ImageModalData(image: image))
//                ImageOverlayViewModel.shared.present(images: [image])
            } label: {
                ImageView(url: url, aspectRatio: image.aspectRatio)
//                    .matchedGeometryEffect(id: image.url, in: imageNS ?? fallbackNS)
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
