//
//  CachedImage.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

struct CachedImageView: View {
    private var loader: ImageLoader
    @State private var image: UIImage?
    
    init(url: URL, targetSize: CGSize) {
        self.loader = ImageLoader(url: url, targetSize: targetSize)
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
//                    .interpolation(.none)
            } else {
                Rectangle()
                    .fill(.background.secondary)
//                    .overlay { ProgressView() }
            }
        }
        .task(id: loader.url) {
            image = try? await loader.loadAndGetImage()
        }
    }
}
