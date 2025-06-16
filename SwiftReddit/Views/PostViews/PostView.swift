//
//  PostView.swift
//  winston
//
//  Created for memory optimization
//

import SwiftUI

struct PostView: View {
  let post: Post
  
  init(post: Post) {
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
                          .fontWeight(.semibold)
                          .padding(.horizontal, 6)
                          .padding(.vertical, 2)
                          .background(post.flairBackgroundColor)
                          .foregroundStyle(post.flairTextColor)
                          .cornerRadius(4)
                  }

                  if !post.selftext.isEmpty {
                      Text(post.selftext.trimmingCharacters(in: .whitespacesAndNewlines))
                          .font(.caption)
                          .foregroundStyle(.secondary)
                          .lineLimit(2)
                  }
              }
              Spacer()
          }
          
          // Media component
          if post.mediaType.hasMedia {
              PostMediaView(mediaType: post.mediaType)
          }
          
          Divider()
          
          // Post metadata
          HStack {
              // Avatar logo or subreddit logo TODO:
              Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundStyle(.secondary)
              
              VStack(alignment: .leading, spacing: 2) {
                  Text(post.subredditNamePrefixed)
                      .font(.caption)
                      .foregroundStyle(.link)
                  
                  HStack(spacing: 10) {
                        HStack(spacing: 4) {
                          Image(systemName: "bubble.left")
                          
                          Text(post.formattedComments)
                        }
                      
                        HStack(spacing: 4) {
                            Image(systemName: "clock")

                            Text(post.timeAgo)
                        }
                  }
                  .font(.caption)
                  .fontWeight(.semibold)
                  .foregroundStyle(.secondary)
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
                .fontWeight(.semibold)
          }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(.background.secondary, in: .rect(cornerRadius: 16))
  }
}
