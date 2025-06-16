//
//  PostImageView.swift
//  winston
//
//  Created for memory optimization -  image display
//

import SwiftUI

struct PostImageView: View {
  let imageURL: String?
  
  var body: some View {
    ZStack {
      if let imageURL = imageURL, let url = URL(string: imageURL) {
        AsyncImage(url: url) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
          Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
              ProgressView()
                .scaleEffect(0.8)
            )
        }
      } else {
        Rectangle()
          .fill(Color.gray.opacity(0.3))
          .overlay(
            Image(systemName: "photo")
              .font(.title2)
              .foregroundColor(.secondary)
          )
      }
    }
    .frame(maxHeight: 300)
    .cornerRadius(8)
    .clipped()
  }
}
