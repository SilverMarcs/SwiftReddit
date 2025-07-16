//
//  ImageLoader.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

enum ImageError: Error {
    case loadFailed
    case taskCancelled
}

class ImageLoader {
    let url: URL
    private let targetSize: CGSize
    private var loadTask: Task<UIImage?, Never>?
    
    init(url: URL, targetSize: CGSize) {
        self.url = url
        self.targetSize = targetSize
    }
    
    func loadAndGetImage() async throws -> UIImage {
        loadTask?.cancel()
        
        return try await Task {
            let sizeKey = "\(Int(targetSize.width))x\(Int(targetSize.height))"
            let cacheKey = "\(url.absoluteString)_\(sizeKey)"
            
            if let cachedImage = await MemoryCache.shared.get(for: cacheKey) {
                return cachedImage
            }
            
            do {
                let image: UIImage?
                
                // Check disk cache first
                if let diskData = await DiskCache.shared.retrieve(for: url.absoluteString) {
                    image = await loadImage(from: diskData)
                } else {
                    // Download if not in disk cache
                    let (data, _) = try await URLSession.shared.data(from: url)
                    await DiskCache.shared.store(data, for: url.absoluteString)
                    image = await loadImage(from: data)
                }
                
                if let finalImage = image {
                    await MemoryCache.shared.insert(finalImage, for: cacheKey)
                    return finalImage
                }
                throw ImageError.loadFailed
            } catch {
                throw ImageError.loadFailed
            }
        }.value
    }
    
    private func loadImage(from data: Data) async -> UIImage? {
        await Task.detached(priority: .userInitiated) {
            let imageSourceOptions = [
                kCGImageSourceShouldCache: false,
                kCGImageSourceShouldAllowFloat: false
            ] as CFDictionary
            
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
                return nil
            }
            
            // More aggressive downsampling with fixed size
            let maxDimension = min(self.targetSize.width, self.targetSize.height) * 2 // Fixed scale factor
            
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: false, // Changed to false
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimension,
                kCGImageSourceShouldAllowFloat: false
            ] as CFDictionary
            
            if let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) {
                return UIImage(cgImage: downsampledImage, scale: 1.0, orientation: .up)
            }
            
            return UIImage(data: data, scale: 1.0)
        }.value
    }
}
