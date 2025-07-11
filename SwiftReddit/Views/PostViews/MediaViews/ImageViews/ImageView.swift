//
//  ImageView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 19/06/2025.
//

import SwiftUI
import Kingfisher
import Kingfisher

struct ImageView: View {
    var url: URL?
    var aspectRatio: CGFloat? = nil // Sensible default aspect ratio
    
    var body: some View {
        KFImage(url)
            .placeholder {
                Rectangle()
                    .fill(.background.secondary)
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .cornerRadius(12)
                    .clipped()
                    .overlay(
                        ProgressView()
                    )
            }
            .downsampling(size: CGSize(width: 1000, height: 1000))
            .serialize(as: .JPEG)
            .fade(duration: 0.1)
            .resizable()
            .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

#Preview {
    ImageView(url: URL(string: "https://example.com/image.jpg"))
        .frame(width: 200, height: 200)
}
