//
//  SaveImageButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import PhotosUI
import CachedAsyncImage
 
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
            // Since we're saving an image that's being displayed, it should be in memory cache
            if let cachedImage = await MemoryCache.shared.get(for: imageURL) {
                try await PHPhotoLibrary.shared().performChanges {
                    @Sendable in
                    PHAssetChangeRequest.creationRequestForAsset(from: cachedImage)
                }
                return
            }
            
            // Fallback: Download if somehow not in memory cache
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let downloadedImage = UIImage(data: data) else { return }
            
            try await PHPhotoLibrary.shared().performChanges {
                @Sendable in
                PHAssetChangeRequest.creationRequestForAsset(from: downloadedImage)
            }
        } catch {
            print("Failed to save image: \(error)")
        }
    }
}
