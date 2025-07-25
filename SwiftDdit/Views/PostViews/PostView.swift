//
//  PostView.swift
//  SwiftDdit
//
//  Created for memory optimization
//

import SwiftUI

struct PostView: View {
    @Environment(\.appendToPath) var appendToPath
    let post: Post
    var isCompact: Bool = true
    var onReplyTap: (() -> Void)? = nil
    @State private var isSaved: Bool
    
    init(post: Post, isCompact: Bool = true, onReplyTap: (() -> Void)? = nil) {
        self.post = post
        self.isCompact = isCompact
        self.onReplyTap = onReplyTap
        self._isSaved = State(initialValue: post.saved)
    }
    
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
                    .font(isCompact ? .callout : .default)
                    .foregroundStyle(isCompact ? .secondary : .primary)
                    .opacity(isCompact ? 1 : 0.9)
                    .lineLimit(isCompact ? 3 : nil)
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
                          
                            Text(post.formattedNumComments)
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
              
              if let onReplyTap = onReplyTap {
                  Button {
                      onReplyTap()
                  } label: {
                      Image(systemName: "arrowshape.turn.up.backward.fill")
                          .font(.headline)
                          .foregroundStyle(.accent)
                          .padding(3)
                  }
                  .buttonStyle(.glass)
                  .buttonBorderShape(.circle)
              } else {
                  toggleSaveButton
                      .font(.headline)
                      .labelStyle(.iconOnly)
                      .buttonStyle(.glass)
                      .controlSize(.regular)
              }
              
              PostActionsView(post: post)
            }
        }
        .padding(.horizontal, isCompact ? 12 : 0)
        .padding(.vertical, isCompact ? 12 : 0)
        .background(isCompact ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 16))
        .contextMenu {
          Section {
              Button {
                  appendToPath(PostFeedType.user(post.author))
              } label: {
                  Label {
                      Text(post.author)
                  } icon: {
                      Image(systemName: "person")
                  }
              }
          }
            
        toggleSaveButton

          if let redditURL = post.redditURL {
              ShareLink(item: redditURL) {
                  Label("Share", systemImage: "square.and.arrow.up")
              }
          }
        } preview: {
            CompactPostView(post: post)
                .padding(15)
        }
    }
    
    func toggleSave() async {
        let success = await RedditAPI.save(!isSaved, id: post.fullname)
        if success {
            isSaved.toggle()
        }
    }
    
    var toggleSaveButton: some View {
        Button {
            Task {
              await toggleSave()
            }
        } label: {
            Label(isSaved ? "Unsave" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                .padding(2)
        }
        .foregroundStyle(isSaved ? .green : .secondary)
    }
}
