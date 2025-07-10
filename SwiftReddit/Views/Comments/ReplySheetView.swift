import SwiftUI

struct ReplySheetView: View {
    @Environment(\.dismiss) private var dismiss
    let replyTo: String // fullname
    let onReplyPosted: () async -> Void
    
    @State private var replyText = ""
    @State private var isPosting = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Write a reply...", text: $replyText, axis: .vertical)
                    .lineLimit(1...6)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Reply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Post") {
                        Task {
                            await postReply()
                        }
                    }
                    .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
                }
            }
            .disabled(isPosting)
        }
    }
    
    private func postReply() async {
        guard !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isPosting = true
        
        let success = await RedditAPI.shared.newReply(replyText, replyTo) ?? false
        
        if success {
            await onReplyPosted()
            dismiss()
        }
        
        isPosting = false
    }
}
