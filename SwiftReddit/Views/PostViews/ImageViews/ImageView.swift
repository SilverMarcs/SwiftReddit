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
    var aspectRatio: CGFloat? = 16/9 // Sensible default aspect ratio
    
    var body: some View {
        KFImage(url)
            .placeholder { // during loading
                Rectangle()
                    .fill(.background.secondary)
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .cornerRadius(12)
                    .clipped()
                    .overlay(
                        ProgressView()
                    )
            }
            .downsampling(size: CGSize(width: 600, height: 600))
            .serialize(as: .JPEG)
            .processingQueue(.dispatch(.global()))
            .fade(duration: 0.1)
            .resizable()
            .aspectRatio(aspectRatio, contentMode: .fit)
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
