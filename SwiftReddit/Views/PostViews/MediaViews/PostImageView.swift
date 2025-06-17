//
//  PostImageView.swift
//  winston
//
//  Created for memory optimization -  image display
//

import SwiftUI

struct PostImageView: View {
  let imageURL: String?
  let dimensions: CGSize?
  
    var body: some View {
        if let imageURL = imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
            .frame(maxHeight: 500)
            .cornerRadius(12)
            .clipped()
    }
  }
  
  private var aspectRatio: CGFloat {
    guard let dimensions = dimensions,
          dimensions.width > 0 && dimensions.height > 0 else {
      return 16/9 // Default aspect ratio
    }
    return dimensions.width / dimensions.height
  }
}
