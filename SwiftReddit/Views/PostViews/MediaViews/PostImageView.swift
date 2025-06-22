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
    @Environment(Nav.self) private var nav
    
    var body: some View {
        if let url = URL(string: image.url) {
            Button {
                nav.path.append(ImageModalData(image: image))
            } label: {
                ImageView(url: url, aspectRatio: image.dimensions.aspectRatio)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: 500,
                        alignment: .center
                    )
                    .cornerRadius(12)
                    .clipped()
                    .matchedTransitionSource(id: image.url, in: zoomNamespace ?? Namespace().wrappedValue)
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
