//
//  SaveImageButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import PhotosUI
import Kingfisher
 
struct SaveImageButton: View {
    let imageURL: String
    @State private var isSaving = false
    
    var body: some View {
        Button {
            Task {
                await saveImage()
            }
        } label: {
            Image(systemName: isSaving ? "checkmark" : "arrow.down")
        }
        .buttonStyle(.glass)
        .controlSize(.large)
        .disabled(isSaving)
    }
    
    private func saveImage() async {
        guard let url = URL(string: imageURL) else { return }
        
        isSaving = true
        defer { isSaving = false }
        
        do {
            // Try to get image from Kingfisher cache first
            if let cachedImage = ImageCache.default.retrieveImageInMemoryCache(forKey: url.absoluteString) {
                try await PHPhotoLibrary.shared().performChanges {
                    @Sendable in
                    PHAssetChangeRequest.creationRequestForAsset(from: cachedImage)
                }
                return
            }
            
            // Fallback to downloading if not cached
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return }
            
            try await PHPhotoLibrary.shared().performChanges {
                @Sendable in
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } catch {
            print("Failed to save image: \(error)")
        }
    }
}
