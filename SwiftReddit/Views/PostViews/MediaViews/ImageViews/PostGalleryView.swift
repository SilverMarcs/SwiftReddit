//
//  PostGalleryView.swift
//  winston
//
//  Created for memory optimization -  gallery display
//

import SwiftUI

struct PostGalleryView: View {
    @Environment(\.imageNS) private var imageNS
    @Environment(\.appendToPath) var appendToPath
    @Namespace private var fallbackNS
    
    let images: [GalleryImage]
    
    // Define grid layout
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 80), spacing: 4)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main image display (always first image)
            if let firstImage = images.first, let url = URL(string: firstImage.url) {
                Button {
                    appendToPath(ImageModalData(images: images, startIndex: 0))
                } label: {
                    ImageView(url: url, aspectRatio: firstImage.aspectRatio)
                        .matchedTransitionSource(id: firstImage.url, in: imageNS ?? fallbackNS)
                        .cornerRadius(12)
                        .clipped()
                }
                .buttonStyle(.plain)
            }
            
            // Thumbnails (next 3 images)
            if images.count > 1 {
                let remainingImages = Array(images.dropFirst())
                let displayImages = Array(remainingImages.prefix(3))
                let remainingCount = remainingImages.count - displayImages.count
                
                HStack(spacing: 8) {
                    ForEach(Array(displayImages.enumerated()), id: \.offset) { index, image in
                        Button {
                            appendToPath(ImageModalData(images: images, startIndex: index + 1))
                        } label: {
                            if let url = URL(string: image.url) {
                                ImageView(url: url)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                                    .matchedTransitionSource(id: image.url, in: imageNS ?? fallbackNS)
                                    .overlay {
                                        // Show overlay on last thumbnail if there are more images
                                        if index == displayImages.count - 1 && remainingCount > 0 {
                                            Rectangle()
                                                .fill(.black.opacity(0.6))
                                                .cornerRadius(8)
                                                .overlay {
                                                    Text("+\(remainingCount)")
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.white)
                                                }
                                        }
                                    }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
