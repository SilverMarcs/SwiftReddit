//
//  LightweightPostView.swift
//  winston
//
//  Created for memory optimization
//

import SwiftUI

struct LightweightPostView: View {
  let post: LightweightPost
  
  init(post: LightweightPost) {
    self.post = post
  }
  
  var body: some View {
      VStack(alignment: .leading, spacing: 8) {
          // Title and flair header
          HStack(alignment: .top) {
              VStack(alignment: .leading, spacing: 4) {
                  // Title
                  Text(post.title)
                      .font(.headline)
                      .fontWeight(.semibold)
                      .lineLimit(3)
                      .multilineTextAlignment(.leading)
                  
                  // Flair if available
                  if let flair = post.linkFlairText, !flair.isEmpty {
                      Text(flair)
                          .font(.caption2)
                          .padding(.horizontal, 6)
                          .padding(.vertical, 2)
                          .background(.background.tertiary)
                          .foregroundColor(.primary)
                          .cornerRadius(4)
                  }
                  
                  // TODO: post type here???
                  
                  // post description a bit here
              }
              
              Spacer()
              
              // NSFW badge
              if post.isNSFW {
                  HStack(spacing: 4) {
                      Image(systemName: "exclamationmark.triangle.fill")
                          .font(.caption2)
                      Text("NSFW")
                          .font(.caption2)
                          .fontWeight(.semibold)
                  }
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(Color.red.opacity(0.9))
                  .foregroundColor(.white)
                  .cornerRadius(6)
              }
          }
          
          // Media component
          if post.mediaType.hasMedia {
              LightweightMediaView(mediaType: post.mediaType)
          }
          
          Divider()
          
          // Post metadata
          HStack {
              // Avatar logo or subreddit logo TODO:
              Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundColor(.secondary)
              
              VStack(alignment: .leading, spacing: 2) {
                  Text(post.subredditNamePrefixed)
                      .font(.caption)
                      .foregroundColor(.secondary)
                  
                  HStack(spacing: 10) {
                        HStack(spacing: 4) {
                          Image(systemName: "bubble.left")
                              .imageScale(.small)
                            .fontWeight(.semibold)
                              .foregroundColor(.secondary)
                          
                          Text(post.formattedComments)
                              .font(.callout)
                              .fontWeight(.semibold)
                              .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .imageScale(.small)
                                .foregroundColor(.secondary)
                            
                            Text(post.timeAgo)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                  }
              }
              
              Spacer()
              
              HStack(alignment: .center) {
                    Image(systemName: "arrow.up")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    Text(post.formattedUps)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "arrow.down")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                .fontWeight(.semibold)
          }
//
//          // Domain/URL info for link posts
//          if !post.isSelf, let url = post.url, !url.isEmpty {
//              Text(post.domain)
//                  .font(.caption2)
//                  .foregroundColor(.blue)
//                  .lineLimit(1)
//          }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(.background.secondary, in: .rect(cornerRadius: 16))
  }
}
