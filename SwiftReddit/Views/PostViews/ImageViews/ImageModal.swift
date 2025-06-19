//
//  ImageModal.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct ImageModal: View {
    let images: [GalleryImage]
    @State private var currentIndex: Int
    
    init(images: [GalleryImage], initialIndex: Int) {
        self.images = images
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    init(image: GalleryImage) {
        self.images = [image]
        self._currentIndex = State(initialValue: 0)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(images.enumerated()), id: \.element) { index, galleryImage in
                ImageView(url: URL(string: galleryImage.url))
                    .zoomable()
                    .tag(index)
            }
        }
        .ignoresSafeArea()
        .tabViewStyle(.page)
    }
}
