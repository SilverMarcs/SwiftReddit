//
//  SaveImageButton.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import PhotosUI
 
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
            var imageToSave: UIImage?
            
            // Try memory cache first
            if let cachedImage = await MemoryCache.shared.get(for: imageURL) {
                imageToSave = cachedImage
            }
            // Try disk cache next
            else if let diskData = await DiskCache.shared.retrieve(for: imageURL),
                    let diskImage = UIImage(data: diskData) {
                imageToSave = diskImage
                // Store in memory cache for future use
                await MemoryCache.shared.insert(diskImage, for: imageURL)
            }
            // Finally, download if not in any cache
            else {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let downloadedImage = UIImage(data: data) else { return }
                imageToSave = downloadedImage
                
                // Store in both caches for future use
                await MemoryCache.shared.insert(downloadedImage, for: imageURL)
                await DiskCache.shared.store(data, for: imageURL)
            }
            
            // Save to photo library
            if let finalImage = imageToSave {
                try await PHPhotoLibrary.shared().performChanges {
                    @Sendable in
                    PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
                }
            }
        } catch {
            print("Failed to save image: \(error)")
        }
    }
}
