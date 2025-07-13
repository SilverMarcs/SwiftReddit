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
        #if os(macOS)
        ZStack {
            // Current Image
            if let currentImage = images[safe: currentIndex] {
                ImageView(url: URL(string: currentImage.url), aspectRatio: currentImage.aspectRatio)
                    .zoomable()
            }
            
            HStack {

                Button(action: previousImage) {
                    Image(systemName: "chevron.left")
                }
                .controlSize(.extraLarge)
                .buttonStyle(.glass)
                .disabled(currentIndex == 0)
                
                Spacer()
                
                Button(action: nextImage) {
                    Image(systemName: "chevron.right")
                }
                .controlSize(.extraLarge)
                .buttonStyle(.glass)
                .disabled(currentIndex == images.count - 1)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        #else
        TabView(selection: $currentIndex) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, galleryImage in
                ImageView(url: URL(string: galleryImage.url), aspectRatio: galleryImage.aspectRatio)
                    .zoomable()
                    .overlay(alignment: .bottomTrailing) {
                        SaveImageButton(imageURL: galleryImage.url)
                            .padding()
                    }
                    .tag(index)
            }
        }
        .ignoresSafeArea()
        .tabViewStyle(.page)
        .navigationTransition(.zoom(sourceID: sourceID, in: imageNS ?? fallbackNS))
        #endif
    }
    
    private func nextImage() {
        guard currentIndex < images.count - 1 else { return }
        currentIndex += 1
    }
    
    private func previousImage() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
}

// Safe array access extension
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

private func saveImageToPhotos(from url: URL) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil,
              let image = UIImage(data: data) else {
            return
        }
        
        DispatchQueue.main.async {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    task.resume()
}
