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
             CachedAsyncImage(url: url) { image in
                 image
                     .resizable()
                     .aspectRatio(contentMode: .fit)
             } placeholder: {
                 Rectangle()
                     .fill(.background.secondary)
                     .aspectRatio(aspectRatio, contentMode: .fit)
                     .overlay(
                         ProgressView()
                     )
             }
        
        // Uncomment below and comment above to use regular AsyncImage
//        AsyncImage(url: url) { image in
//            image
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//        } placeholder: {
//            Rectangle()
//                .fill(.background.secondary)
//                .aspectRatio(aspectRatio, contentMode: .fit)
//                .overlay(
//                    ProgressView()
//                )
//        }
    }
}

#Preview {
    ImageView(url: URL(string: "https://example.com/image.jpg"))
        .frame(width: 200, height: 200)
}
