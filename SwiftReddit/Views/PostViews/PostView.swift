//
//  PostView.swift
//  winston
//
//  Created for memory optimization
//

import SwiftUI

struct PostView: View {
    @Environment(Nav.self) var nav
    @Environment(\.isHomeFeed) private var isHomeFeed
    let post: Post
    var isCompact: Bool = true
  
  var body: some View {
      VStack(alignment: .leading, spacing: 8) {
          // Title and flair header
            Text(post.title)
//              .font(.title3) // title3 is fine
                .font(.system(size: 19)) // title3 is fine
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
//                Text(LocalizedStringKey(isCompact ? String(post.selftext.prefix(100)) : post.selftext))
                Text(LocalizedStringKey(post.selftext))
//                    .font(.subheadline)
                    .font(.callout)
                    .foregroundStyle(isCompact ? .secondary : .primary)
                    .opacity(isCompact ? 1 : 0.9)
                    .lineLimit(isCompact ? 3 : nil)
                    .environment(\.openURL, OpenURLAction { url in
                        let linkMetadata = LinkMetadata(
                            url: url.absoluteString,
                            domain: url.host ?? "Unknown",
                            thumbnailURL: nil
                        )

                        nav.path.append(linkMetadata)

                        return .handled
                    })
        }
          
          // Media component
          if post.mediaType.hasMedia {
              PostMediaView(mediaType: post.mediaType)
          }
          
          Divider()
          
          // Post metadata
          HStack {
//              SubredditButton(subreddit: post.subreddit, type: .icon(iconUrl: post.subreddit.iconURL ?? ""))
              
              VStack(alignment: .leading, spacing: 3) {
                  if isHomeFeed {
                      SubredditButton(subreddit: post.subreddit, type: .text)
                  } else {
                      Text("u/\(post.author)")
                          .font(.caption)
                          .foregroundStyle(.cyan)
                  }
                  
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
  }
}
