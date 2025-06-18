//
//  ImagePreviewModal.swift
//  SwiftReddit
//
//  Created for reusable image preview modal
//

import SwiftUI

struct ImagePreviewModal: View {
    @Environment(\.dismiss) private var dismiss
    let imageURL: String
    
    var body: some View {
        NavigationStack {
            if let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    ZoomableImage(image: image)
                } placeholder: {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ImagePreviewModal(imageURL: "https://picsum.photos/800/600")
}
