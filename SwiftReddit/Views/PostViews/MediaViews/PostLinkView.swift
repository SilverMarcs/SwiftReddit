//
//  PostLinkView.swift
//  winston
//
//  Created for memory optimization -  link display
//

import SwiftUI
import WebKit

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
          .background(
              RoundedRectangle(
                  cornerRadius: 12,
              )
              .fill(.background.secondary)
//          .stroke(.separator, lineWidth: 1)
          )
      }
      .buttonStyle(.plain)
    }
}
