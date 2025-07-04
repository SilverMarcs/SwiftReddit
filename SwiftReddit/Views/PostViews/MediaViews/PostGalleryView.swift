//
//  PostGalleryView.swift
//  winston
//
//  Created for memory optimization -  gallery display
//

import SwiftUI

struct PostGalleryView: View {
    @Environment(Nav.self) private var nav
    @Environment(\.imageZoomNamespace) private var zoomNamespace
    let images: [GalleryImage]
    
    var body: some View {
        HStack(spacing: 4) {
            Button {
                nav.path.append(ImageModalData(images: images))
            } label: {
                ImageView(url: URL(string: images[0].url), aspectRatio: images[0].aspectRatio)
                    .cornerRadius(12)
                    .clipped()
                    .frame(maxHeight: 300)
                    .matchedTransitionSource(id: images[0].url, in: zoomNamespace ?? Namespace().wrappedValue)
            }
            .buttonStyle(.plain)
            
            Button {
                nav.path.append(ImageModalData(images: images))
            } label: {
                // TODO: make clickable and show more
                ImageView(url: URL(string: images[1].url), aspectRatio: images[1].aspectRatio)
                    .cornerRadius(12)
                    .clipped()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .overlay {
                        if images.count > 2 {
                            Color.black.opacity(0.5)
                            
                            Text("+\(images.count - 2)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    PostGalleryView(
        images: [
            GalleryImage(url: "https://picsum.photos/800/600", dimensions: CGSize(width: 800, height: 600)),
            GalleryImage(url: "https://picsum.photos/600/800", dimensions: CGSize(width: 600, height: 800)),
            GalleryImage(url: "https://picsum.photos/700/500", dimensions: CGSize(width: 700, height: 500)),
            GalleryImage(url: "https://picsum.photos/900/700", dimensions: CGSize(width: 900, height: 700))
        ]
    )
    .padding()
}
