//
//  ImageViewer.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(\.dismiss) private var dismiss
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
        NavigationStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.element) { index, galleryImage in
                    AsyncImage(url: URL(string: galleryImage.url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .zoomable()
                    } placeholder: {
                        ProgressView()
                            .controlSize(.large)
                    }
                    .tag(index)
                }
            }
            .ignoresSafeArea()
            .tabViewStyle(.page)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
