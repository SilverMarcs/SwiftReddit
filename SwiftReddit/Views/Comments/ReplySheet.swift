//
//  ReplySheet.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct ReplySheet: View {
    @Environment(\.dismiss) var dismiss
    let target: ReplyTarget
    let onReply: (String, String) -> Void
    
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
            .navigationTitle(target.title)
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
                        Task {
                            await submitReply()
                        }
                    } label: {
                        Label("Reply", systemImage: "arrow.up")
                    }
                    .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func submitReply() async {
        onReply(replyText.trimmingCharacters(in: .whitespacesAndNewlines), target.fullname)

        dismiss()
    }
    
    enum ReplyTarget {
        case post(Post)
        case comment(Comment)
        
        var fullname: String {
            switch self {
            case .post(let post): return "t3_\(post.id)"
            case .comment(let comment): return "t1_\(comment.id)"
            }
        }
        
        var title: String {
            switch self {
            case .post: return "Reply to Post"
            case .comment: return "Reply to Comment"
            }
        }
    }
}
