//
//  ReplySheet.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct ReplySheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.addOptimisticComment) var addOptimisticComment
    
    let parentId: String
    
    @State private var replyText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Write your reply...", text: $replyText, axis: .vertical)
                
                Spacer()
            }
            .padding()
            .textFieldStyle(.plain)
            .focused($isTextFieldFocused)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isTextFieldFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        submitReply()
                    } label: {
                        Label("Reply", systemImage: "arrow.up")
                    }
                    .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func submitReply() {
        guard !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add optimistic comment immediately (includes network request)
        addOptimisticComment(replyText, parentId)
        
        dismiss()
    }
}
