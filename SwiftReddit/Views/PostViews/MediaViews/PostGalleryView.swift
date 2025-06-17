//
//  PostGalleryView.swift
//  winston
//
//  Created for memory optimization -  gallery display
//

import SwiftUI

struct PostGalleryView: View {
    let images: [GalleryImage]
    
    var body: some View {
        if images.count == 1 {
            singleImageView
        } else {
            twoImageView
        }
    }
    
    // Single image layout
    private var singleImageView: some View {
        imageView(for: images[0])
    }
    
    // Two image layout - side by side with potential overlay
    private var twoImageView: some View {
        HStack {
            // First image
            imageView(for: images[0])
            
            // Second image with potential overlay
            ZStack {
                imageView(for: images[1])
                
                // Show remaining count if more than 2 images
                if images.count > 2 {
                    Color.black.opacity(0.6)
                    
                    Text("+\(images.count - 2)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // Image view implementation to replace PostImageView dependency
    private func imageView(for galleryImage: GalleryImage) -> some View {
        AsyncImage(url: URL(string: galleryImage.url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(aspectRatio(for: galleryImage.dimensions), contentMode: .fit)
                .overlay(
                    ProgressView()
                        .scaleEffect(0.8)
                )
        }
        .frame(maxHeight: 500)
        .cornerRadius(12)
        .clipped()
    }
    
    // Calculate aspect ratio from dimensions
    private func aspectRatio(for dimensions: CGSize) -> CGFloat {
        guard dimensions.width > 0 && dimensions.height > 0 else {
            return 16/9 // Default aspect ratio
        }
        return dimensions.width / dimensions.height
    }
}
