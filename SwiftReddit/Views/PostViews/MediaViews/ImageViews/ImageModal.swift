//
//  ImageModal.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct ImageModal: View {
    let images: [GalleryImage]
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    @State private var currentIndex: Int = 0
    
    private var sourceID: String {
        guard currentIndex < images.count else { return images.first?.url ?? "" }
        return images[currentIndex].url
    }
    
    init(imageData: ImageModalData) {
        self.images = imageData.images
        self._currentIndex = State(initialValue: imageData.startIndex)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, galleryImage in
                ImageView(url: URL(string: galleryImage.url), aspectRatio: galleryImage.aspectRatio)
                    .zoomable()
                    .tag(index)
            }
        }
        .ignoresSafeArea()
        #if !os(macOS)
        .tabViewStyle(.page)
        .navigationTransition(.zoom(sourceID: sourceID, in: imageNS ?? fallbackNS))
        #endif
    }
}
