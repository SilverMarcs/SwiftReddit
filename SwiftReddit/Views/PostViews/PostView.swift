//
//  PostView.swift
//  winston
//
//  Created for memory optimization
//

import SwiftUI

struct PostView: View {
    @Environment(Nav.self) var nav
  let post: Post
  var isCompact: Bool = true
  
  var body: some View {
      VStack(alignment: .leading, spacing: 8) {
          // Title and flair header
            Text(post.title)
                .font(.system(size: 18)) // title3 is fine
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
                Text(LocalizedStringKey(post.selftext))
                    .font(.subheadline)
                    .foregroundStyle(isCompact ? .secondary : .primary)
                    .opacity(isCompact ? 1 : 0.9)
                    .lineLimit(isCompact ? 3 : nil)
        }
          
          // Media component
          if post.mediaType.hasMedia {
              PostMediaView(mediaType: post.mediaType)
          }
          
          Divider()
          
          // Post metadata
          HStack {
              SubredditButton(subreddit: post.subreddit, type: .icon(iconUrl: post.subreddit.iconURL ?? ""))
              
              VStack(alignment: .leading, spacing: 2) {
                  SubredditButton(subreddit: post.subreddit, type: .text)
                      
                  
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
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "arrow.down")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .fontWeight(.semibold)
          }
      }
      .padding(.horizontal, isCompact ? 16 : nil)
      .padding(.vertical, isCompact ? 12 : nil)
      .background(isCompact ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 16))
      .environment(\.openURL, OpenURLAction { url in
          let linkMetadata = LinkMetadata(
              url: url.absoluteString,
              domain: url.host ?? "Unknown",
              thumbnailURL: nil
          )

//                      nav.path.append(linkMetadata)
                          nav.navigateToLink(linkMetadata)


          return .handled
      })
  }
}
