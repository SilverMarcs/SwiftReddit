//
//  MessageRowView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct MessageRowView: View {
    @Environment(Nav.self) private var nav
    let message: Message
    
    private var iconConfig: (symbol: String, color: Color) {
        switch message.type {
        case "post_reply":
            return ("message.circle.fill", .blue)
        case "comment_reply":
            return ("arrowshape.turn.up.left.circle.fill", .green)
        case "unknown", _:
            return ("bell.circle.fill", .accent) // For announcements and unknown types
        }
    }
    
    var body: some View {
        Button {
            if let postNavigation = message.postNavigation {
                nav.path.append(postNavigation)
            }
        } label: {
            HStack(alignment: .top) {
                Image(systemName: iconConfig.symbol)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(iconConfig.color)
                
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
