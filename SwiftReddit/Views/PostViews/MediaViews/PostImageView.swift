//
//  PostImageView.swift
//  winston
//
//  Created for memory optimization -  image display
//

import SwiftUI

struct PostImageView: View {
    let imageURL: String?
    let dimensions: CGSize?
    @State private var showFullscreen = false
    
    var body: some View {
        if let imageURL = imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        showFullscreen = true
                    }
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
            .sheet(isPresented: $showFullscreen) {
                NavigationStack {
                    ZoomableImageModal(imageURL: imageURL)
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
    }
    
    private var aspectRatio: CGFloat {
        guard let dimensions = dimensions,
              dimensions.width > 0 && dimensions.height > 0 else {
            return 16/9 // Default aspect ratio
        }
        return dimensions.width / dimensions.height
    }
}

struct ZoomableImageModal: View {
    let imageURL: String
    
    var body: some View {
        if let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                ZoomableImage(image: image)
            } placeholder: {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }
}

#Preview {
    PostImageView(
        imageURL: "https://picsum.photos/800/600",
        dimensions: CGSize(width: 800, height: 600)
    )
    .padding()
}
