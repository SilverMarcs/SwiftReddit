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
//              .font(.title3) // title3 is fine
                .font(.system(size: 19)) // title3 is fine
                .fontWeight(.semibold)
                .lineLimit(isCompact ? 3 : nil)
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
          
          // ADD NSFW BADGE

            if !post.selftext.isEmpty {
                Text(LocalizedStringKey(post.selftext))
//                    .font(.subheadline)
                    .font(.callout)
                    .foregroundStyle(isCompact ? .secondary : .primary)
                    .opacity(isCompact ? 1 : 0.9)
                    .lineLimit(isCompact ? 3 : nil)
                    .handleURLs()
        }
          
          // Media component
          if post.mediaType.hasMedia {
              PostMediaView(mediaType: post.mediaType)
          }
          
          Divider()
          
          // Post metadata
          HStack {
              SubredditButton(subreddit: post.subreddit, type: .icon(iconUrl: post.subreddit.iconURL ?? ""))
              
              VStack(alignment: .leading, spacing: 3) {
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
      .padding(.horizontal, isCompact ? 12 : nil)
      .padding(.vertical, isCompact ? 12 : nil)
      .background(isCompact ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 16))
//      .background(
//        RoundedRectangle(cornerRadius: 16)
//          .fill(isCompact ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear))
//          .stroke(.separator, lineWidth: 1)
//      )
      // simpel stoke all round
//      .background(RoundedRectangle(cornerRadius: 16).stroke(.separator, lineWidth: 1))
      .contextMenu {
          Section {
              Button {
                  nav.path.append(PostFeedType.user(post.author))
              } label: {
                  Label {
                      Text(post.author)
                  } icon: {
                      Image(systemName: "person")
                  }
              }
          }
          
          Button {
              Task {
                  await RedditAPI.shared.save(!post.saved, id: post.fullname)
              }
          } label: {
              Label(post.saved ? "Unsave" : "Save", systemImage: post.saved ? "bookmark.fill" : "bookmark")
          }
          
          if let redditURL = post.redditURL {
              ShareLink(item: redditURL) {
                  Label("Share", systemImage: "square.and.arrow.up")
              }
          }
      }
  }
}
