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
        imageView(for: images[0])
            .onTapGesture {
                selectedIndex = 0
                showFullscreen = true
            }
            .fullScreenCover(isPresented: $showFullscreen) {
                ZoomableGalleryModal(images: images, initialIndex: selectedIndex)
            }
    }
    
    // Multiple images layout - always show only two images max
    private var multipleImagesView: some View {
        HStack(spacing: 4) {
            // First image
            imageView(for: images[0])
                .onTapGesture {
                    selectedIndex = 0
                    showFullscreen = true
                }
            
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
            .onTapGesture {
                selectedIndex = 1
                showFullscreen = true
            }
        }
        .sheet(isPresented: $showFullscreen) {
            NavigationStack {
                ZoomableGalleryModal(images: images, initialIndex: selectedIndex)
                    .toolbar {
                         ToolbarItem(placement: .primaryAction) {
                             Button {
                                 showFullscreen = false
                             } label: {
                                 Image(systemName: "xmark")
                             }
                         }
                     }
            }
   
        }
    }
    
    // Image view implementation
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
