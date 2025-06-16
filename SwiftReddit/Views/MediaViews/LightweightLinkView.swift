//
//  LightweightLinkView.swift
//  winston
//
//  Created for memory optimization - lightweight link display
//

import SwiftUI

struct LightweightLinkView: View {
  let thumbnailURL: String?
  let isNSFW: Bool
  
  var body: some View {
    ZStack {
      if let thumbnailURL = thumbnailURL {
        LightweightImageView(imageURL: thumbnailURL, isNSFW: isNSFW)
      } else {
        Rectangle()
          .fill(Color.gray.opacity(0.2))
          .frame(height: 80)
          .overlay(
            HStack {
              Image(systemName: "link")
                .font(.title2)
                .foregroundColor(.secondary)
              Text("External Link")
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
          )
          .cornerRadius(8)
      }
      
      if thumbnailURL != nil {
        VStack {
          Spacer()
          HStack {
            Image(systemName: "link")
              .font(.caption)
            Text("Link")
              .font(.caption)
              .fontWeight(.medium)
            Spacer()
          }
          .foregroundColor(.white)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.gray.opacity(0.8))
          .cornerRadius(4)
          .padding(8)
        }
      }
    }
  }
}
