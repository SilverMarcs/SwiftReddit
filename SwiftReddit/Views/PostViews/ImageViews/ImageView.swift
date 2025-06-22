//
//  ImageView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 19/06/2025.
//

import SwiftUI

struct ImageView: View {
    var url: URL?
    var aspectRatio: CGFloat? = 16/9 // Sensible default aspect ratio
    
    var body: some View {
        // Easy place to switch between implementations
        
        CachedAsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure(let error):
                largeImagePlaceholder
            @unknown default:
                failurePlaceholder
            }
        }
        
        // Uncomment below and comment above to use regular AsyncImage
//        AsyncImage(url: url) { image in
//            image
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//        } placeholder: {
//            placeholder
//        }
    }
    
    var placeholder: some View {
        Rectangle()
            .fill(.background.secondary)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay(
                ProgressView()
            )
    }
    
    var failurePlaceholder: some View {
        Rectangle()
            .fill(.background.secondary)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay(
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .imageScale(.large)
            )
    }
    
    var largeImagePlaceholder: some View {
        Button {
            // open url in safari
            if let url = url {
                #if os(macOS)
                NSWorkspace.shared.open(url)
                #else
                UIApplication.shared.open(url)
                #endif
            }
        } label: {
            Rectangle()
                .fill(.background.secondary)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .overlay(
                    Text("Click image to load")
                )
        }
    }
}

#Preview {
    ImageView(url: URL(string: "https://example.com/image.jpg"))
        .frame(width: 200, height: 200)
}
