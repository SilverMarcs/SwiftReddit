//
//  ReplySheet.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct ReplySheet: View {
    @Environment(\.dismiss) var dismiss
    
    let parentId: String
    let isTopLevel: Bool
    let onSubmit: (String, String) -> Void
    
    @State private var replyText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(isTopLevel ? "Write a comment..." : "Write your reply...", text: $replyText, axis: .vertical)
                
                Spacer()
            }
            .padding()
            .textFieldStyle(.plain)
            .focused($isTextFieldFocused)
            .navigationTitle("Reply to \(isTopLevel ? "post" : "comment")")
            .toolbarTitleDisplayMode(.inline)
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
                        Label(isTopLevel ? "Comment" : "Reply", systemImage: "arrow.up")
                    }
                    .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func submitReply() {
        guard !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        onSubmit(replyText, parentId)
        dismiss()
    }
}
