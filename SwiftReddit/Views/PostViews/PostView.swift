//
//  PostView.swift
//  winston
//
//  Created for memory optimization
//

import SwiftUI

struct PostView: View {
  let post: Post
  var showBackground: Bool = true
  var truncateSelfText: Bool = true
  
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
                Text(LocalizedStringKey(post.selftext.trimmingCharacters(in: .whitespacesAndNewlines)))
                    .font(.subheadline)
                    .foregroundStyle(truncateSelfText ? .secondary : .primary)
                    .lineLimit(truncateSelfText ? 3 : nil)
        }
          
          // Media component
          if post.mediaType.hasMedia {
              PostMediaView(mediaType: post.mediaType)
          }
          
          Divider()
          
          // Post metadata
          HStack {
              // Subreddit icon
              if let iconURL = post.subredditIconURL, let url = URL(string: iconURL) {
                  AsyncImage(url: url) { image in
                      image
                          .resizable()
                          .aspectRatio(contentMode: .fill)
                  } placeholder: {
                      Image(systemName: "person.crop.circle.fill")
                          .foregroundStyle(.secondary)
                  }
                  .frame(width: 32, height: 32)
                  .clipShape(Circle())
              } else {
                  Image(systemName: "person.crop.circle.fill")
                      .font(.title)
                      .foregroundStyle(.secondary)
              }
              
              VStack(alignment: .leading, spacing: 2) {
                  HStack(spacing: 4) {
                      Text(post.subredditNamePrefixed)
                          .font(.caption)
                          .foregroundStyle(.link)
                      
//                      Text("•")
//                          .font(.caption)
//                          .foregroundStyle(.secondary)
//                      
//                      Text("u/\(post.author)")
//                          .font(.caption)
//                          .foregroundStyle(.secondary)
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
      .padding(.horizontal, truncateSelfText ? 16 : nil)
      .padding(.vertical, truncateSelfText ? 12 : nil)
      .background(showBackground ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 16))
  }
}
