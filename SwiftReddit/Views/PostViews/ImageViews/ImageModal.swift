//
//  ImageModal.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct ImageModal: View {
    let images: [GalleryImage]
    @Environment(\.imageZoomNamespace) private var zoomNamespace
    
    private var sourceID: String {
        images.first?.url ?? ""
    }
    
    private var namespace: Namespace.ID {
        zoomNamespace ?? Namespace().wrappedValue
    }
    
    init(images: [GalleryImage]) {
        self.images = images
    }
    
    init(image: GalleryImage) {
        self.images = [image]
    }
    
    var body: some View {
        TabView {
            ForEach(images) { galleryImage in
                ImageView(url: URL(string: galleryImage.url), aspectRatio: galleryImage.aspectRatio)
                    .zoomable()
                    .tag(galleryImage.id)
            }
        }
        .ignoresSafeArea()
        #if !os(macOS)
        .tabViewStyle(.page)
        .navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        #endif
    }
}
