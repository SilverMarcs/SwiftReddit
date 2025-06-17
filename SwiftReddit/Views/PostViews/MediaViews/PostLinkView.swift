//
//  PostLinkView.swift
//  winston
//
//  Created for memory optimization -  link display
//

import SwiftUI

struct PostLinkView: View {
  let metadata: LinkMetadata
  
  var body: some View {
    HStack(spacing: 12) {
        Image(systemName: "link")
            .imageScale(.large)
            .fontWeight(.bold)
          .foregroundStyle(.secondary)
        
        Text(metadata.domain.lowercased())
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundStyle(.secondary)
        
        Spacer()
        
        if let thumbnailURL = metadata.thumbnailURL, let url = URL(string: thumbnailURL) {
            AsyncImage(url: url) { image in
                image
                  .resizable()
                  .frame(width: 90, height: 60)
                  .cornerRadius(12)
                .clipped()
                  .aspectRatio(contentMode: .fill)
              } placeholder: {
                Rectangle()
                  .fill(Color.gray.opacity(0.3))
                  .frame(width: 90, height: 60)
                  .overlay(
                    ProgressView()
                      .scaleEffect(0.8)
                  )
              }
        }
    }
    .padding(10)
    .background(.background.tertiary)
    .cornerRadius(12)
    .onTapGesture {
      // TODO: Open link in Safari or in-app browser
      if let url = URL(string: metadata.url) {
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
      }
    }
  }
}
