//
//  SubredditInfoView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 19/06/2025.
//

import SwiftUI

struct SubredditInfoView: View {
    let subreddit: Subreddit
    
    var body: some View {
        Form {
            LabeledContent("Subreddit", value: subreddit.displayNamePrefixed)
            
            Section("Statistics") {
                LabeledContent("Subscribers", value: "\(subreddit.subscriberCount.formatted())")
                LabeledContent {
                    Image(systemName: subreddit.isSubscribed ? "checkmark.circle.fill" : "cross.circle.fill")
                        .foregroundStyle(subreddit.isSubscribed ? .green : .red)
                } label: {
                    Text("Subscribed")
                }
                    
            }
            
            Section("Description") {
                Text(subreddit.publicDescription.isEmpty ? "No description available" : subreddit.publicDescription)
                    .font(.body)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    SubredditInfoView(subreddit: Subreddit(
        id: "test",
        displayName: "SwiftUI",
        displayNamePrefixed: "r/SwiftUI",
        iconURL: nil,
        subscriberCount: 50000,
        isSubscribed: false,
        publicDescription: "A community for learning and developing iOS apps using SwiftUI",
        color: .blue
    ))
}
