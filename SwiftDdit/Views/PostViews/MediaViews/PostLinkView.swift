//
//  PostLinkView.swift
//  SwiftDdit
//
//  Created for memory optimization -  link display
//

import SwiftUI
import CachedAsyncImage

struct PostLinkView: View {
  @Environment(\.openURL) var openURL
  @Environment(\.appendToPath) var appendToPath
  let metadata: LinkMetadata
  
  var body: some View {
      Button {
          openURL(URL(string: metadata.url)!, prefersInApp: true)
      } label: {
          HStack(spacing: 12) {
              Image(systemName: "link")
                  .imageScale(.large)
                  .fontWeight(.bold)
                  .foregroundStyle(.blue)
              
              Text(metadata.domain.lowercased())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
              
              Spacer()
              
              if let thumbnailURL = metadata.thumbnailURL, let url = URL(string: thumbnailURL) {
                  CachedAsyncImage(url: url, targetSize: CGSize(width: 100, height: 100))
                      .frame(width: 90, height: 60)
                      .cornerRadius(12)
                      .clipped()
              }
          }
          .padding(10)
          .background(.background.secondary, in: .rect(cornerRadius: 12))
      }
      .buttonStyle(.plain)
    }
}
