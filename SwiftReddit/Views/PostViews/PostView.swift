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
            Text(post.title)
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
                    .font(.callout)
                    .foregroundStyle(isCompact ? .secondary : .primary)
                    .opacity(isCompact ? 1 : 0.9)
                    .lineLimit(isCompact ? 3 : nil)
                    .handleURLs()
        }
          
          if post.mediaType.hasMedia {
              PostMediaView(mediaType: post.mediaType)
          }
          
          Divider()
          
          HStack {
              SubredditButton(subreddit: post.subreddit, type: .icon(iconUrl: post.subreddit.iconURL ?? ""))
              
              VStack(alignment: .leading, spacing: 3) {
                  SubredditButton(subreddit: post.subreddit, type: .text)
                  
                  HStack(spacing: 10) {
                        HStack(spacing: 4) {
                          Image(systemName: "bubble.left")
                          
                            Text(post.numComments.formatted)
                        }
                      
                        HStack(spacing: 4) {
                            Image(systemName: "clock")

                            Text(post.created.timeAgo)
                        }
                  }
                  .font(.caption)
                  .fontWeight(.semibold)
                  .foregroundStyle(.secondary)
              }
              
              Spacer()
              
              PostActionsView(post: post)
          }
      }
      .padding(.horizontal, isCompact ? 12 : nil)
      .padding(.vertical, isCompact ? 12 : nil)
      .background(isCompact ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 16))
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
