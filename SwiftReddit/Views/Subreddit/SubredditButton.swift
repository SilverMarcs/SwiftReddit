//
//  SubredditButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct SubredditButton: View {
    @Environment(AppConfig.self) private var config
    let postList: PostListingId
    let type: SubRedditButtonType
    
    var body: some View {
        Button {
            config.path.append(postList)
        } label: {
            switch type {
            case .text:
                Text(postList.withSubredditPrefix)
                    .font(.caption)
                    .foregroundStyle(.link)
            case .icon(let iconURL):
                if let url = URL(string: iconURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "r.circle")
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "r.circle")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

enum SubRedditButtonType {
    case icon(iconUrl: String)
    case text
}

#Preview {
    SubredditButton(postList: "", type: .text)
}
