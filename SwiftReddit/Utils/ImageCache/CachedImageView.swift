//
//  CachedImage.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

struct CachedImageView: View {
    private var loader: ImageLoader
    #if os(macOS)
    @State private var image: NSImage?
    #else
    @State private var image: UIImage?
    #endif
    
    init(url: URL, targetSize: CGSize) {
        self.loader = ImageLoader(url: url, targetSize: targetSize)
    }
    
    var body: some View {
        Group {
            if let image = image {
                #if os(macOS)
                Image(nsImage: image)
                    .resizable()
//                    .interpolation(.none)
                #else
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                #endif
            } else {
                Rectangle()
                    .fill(.secondary)
            }
        }
        .task(id: loader.url) {
            image = try? await loader.loadAndGetImage()
        }
    }
}
