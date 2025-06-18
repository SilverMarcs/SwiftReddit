//
//  ZoomableGalleryModal.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct ZoomableGalleryModal: View {
    let images: [GalleryImage]
    @State private var currentIndex: Int
    
    init(images: [GalleryImage], initialIndex: Int) {
        self.images = images
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(images.enumerated()), id: \.element) { index, galleryImage in
                AsyncImage(url: URL(string: galleryImage.url)) { image in
                    ZoomableImage(image: image)
                } placeholder: {
                    ProgressView()
                        .controlSize(.large)
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}
