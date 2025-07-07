//
//  PostLinkView.swift
//  winston
//
//  Created for memory optimization -  link display
//

import SwiftUI

struct PostLinkView: View {
  @Environment(Nav.self) private var nav
  let metadata: LinkMetadata
  
  var body: some View {
      Button {
          nav.path.append(metadata)
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
                  ImageView(url: url)
                      .frame(width: 90, height: 60)
                      .cornerRadius(12)
                      .clipped()
              }
          }
          .padding(10)
          .background(.background.secondary, in: .rect(cornerRadius: 12))
//              RoundedRectangle(
//                  cornerRadius: 12,
//              )
//              .fill(.background.tertiary)
//          )
      }
      .buttonStyle(.plain)
      .handleURLs()
    }
}
