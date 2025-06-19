//
//  PostGalleryView.swift
//  winston
//
//  Created for memory optimization -  gallery display
//

import SwiftUI

struct PostGalleryView: View {
    let images: [GalleryImage]
    @State private var showFullscreen = false
    @State private var selectedIndex = 0
    
    var body: some View {
        if images.count == 1 {
            singleImageView
        } else {
            multipleImagesView
        }
    }
    
    // Single image layout
    private var singleImageView: some View {
        Button {
            selectedIndex = 0
            showFullscreen = true
        } label: {
            imageView(for: images[0])
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showFullscreen) {
            ImageModal(images: images, initialIndex: selectedIndex)
        }
    }
    
    // Multiple images layout - always show only two images max
    private var multipleImagesView: some View {
        HStack(spacing: 4) {
            // First image
            Button {
                selectedIndex = 0
                showFullscreen = true
            } label: {
                imageView(for: images[0])
            }
            .buttonStyle(.plain)
            
            // Second image with potential overlay
            Button {
                selectedIndex = 1
                showFullscreen = true
            } label: {
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
                .cornerRadius(12)
                .clipped()
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showFullscreen) {
            ImageModal(images: images, initialIndex: selectedIndex)
        }
    }
    
    // Image view implementation
    private func imageView(for galleryImage: GalleryImage) -> some View {
        ImageView(url: URL(string: galleryImage.url), aspectRatio: aspectRatio(for: galleryImage.dimensions))
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
