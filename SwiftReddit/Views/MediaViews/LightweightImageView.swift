//
//  LightweightImageView.swift
//  winston
//
//  Created for memory optimization - lightweight image display
//

import SwiftUI

struct LightweightImageView: View {
  let imageURL: String?
  let isNSFW: Bool
  
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
      
      // NSFW Badge in top-left corner
      if isNSFW {
        VStack {
          HStack {
            HStack(spacing: 4) {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption2)
              Text("NSFW")
                .font(.caption2)
                .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.9))
            .cornerRadius(6)
            .padding(8)
            Spacer()
          }
          Spacer()
        }
      }
    }
    .frame(maxHeight: 300)
    .cornerRadius(8)
    .clipped()
  }
}
