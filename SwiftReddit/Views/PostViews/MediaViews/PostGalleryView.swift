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
        PostImageView(imageURL: images[0].url, dimensions: images[0].dimensions)
    }
    
    // Two image layout - side by side with potential overlay
    private var twoImageView: some View {
        HStack {
            // First image
            PostImageView(imageURL: images[0].url, dimensions: images[0].dimensions)
            
            // Second image with potential overlay
            ZStack {
                PostImageView(imageURL: images[1].url, dimensions: images[1].dimensions)
                
                // Show remaining count if more than 2 images
                if images.count > 2 {
                    Color.black.opacity(0.6)
                    
                    VStack {
                        Image(systemName: "photo.stack")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("+\(images.count - 2)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}
