//
//  MessageRowView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct MessageRowView: View {
    @Environment(\.appendToPath) var appendToPath
    let message: Message
    
    var body: some View {
        Button {
            if let postNavigation = message.postNavigation {
                appendToPath(postNavigation)
            } else {
                appendToPath(Destination.message(message))
            }
        } label: {
            HStack(alignment: .top) {
                Image(systemName: message.iconConfig.symbol)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(message.iconConfig.color)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Message content
                    if let body = message.body, !body.isEmpty {
                        Text(body)
                            .lineLimit(2)
                            .font(.subheadline)
                    }
                    
                    // Link title if it's a comment reply
                    if let linkTitle = message.linkTitle, !linkTitle.isEmpty {
                        Text("Re: \(linkTitle)")
                            .font(.caption)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                    
                    HStack {
                        if let subreddit = message.subredditNamePrefixed {
                            Text(subreddit)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if let author = message.author {
                            Text("u/\(author)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if let timeAgo = message.created?.timeAgo {
                            Text(timeAgo)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
