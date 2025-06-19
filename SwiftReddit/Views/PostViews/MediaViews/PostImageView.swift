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
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
                .frame(maxHeight: 500)
                .cornerRadius(12)
                .clipped()
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showFullscreen) {
                ImagePreviewModal(imageURL: image.url)
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
