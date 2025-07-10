//
//  InboxView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct InboxView: View {
    @State private var messages: [Message] = []
    @State private var isLoading = false
    @State private var after: String?
    @State private var isLoadingMore = false
    
    var body: some View {
        List {
            if isLoading && messages.isEmpty {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
            }
            
            ForEach(messages, id: \.id) { message in
                MessageRowView(message: message)
            }
            
            Color.clear
                .frame(height: 1)
                .onAppear {
                    Task {
                        await loadMoreMessages()
                    }
                }
                .listRowSeparator(.hidden)
            
            if isLoadingMore {
                ProgressView()
                    .id(UUID())
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
//        .listStyle(.plain)
        .contentMargins(.top, 5)
        .navigationTitle("Inbox")
        .toolbarTitleDisplayMode(.inline)
        .refreshable {
            await fetchMessages()
        }
        .task {
            guard messages.isEmpty else { return }
            await fetchMessages()
        }
    }
    
    private func fetchMessages() async {
        isLoading = true
        defer { isLoading = false }
        
        if let result = await RedditAPI.shared.fetchInbox() {
            messages = result.0 ?? []
            after = result.1
        }
    }
    
    private func loadMoreMessages() async {
        guard !isLoadingMore, let after = after, !after.isEmpty else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        if let result = await RedditAPI.shared.fetchInbox(after: after) {
            let newMessages = result.0 ?? []
            messages.append(contentsOf: newMessages)
            self.after = result.1
        }
    }
}

#Preview {
    InboxView()
}
