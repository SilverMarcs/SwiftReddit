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
    
//    private func loadImage(from data: Data) async -> UIImage? {
//        await Task.detached(priority: .userInitiated) {
//            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
//            guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
//                return nil
//            }
//            
//            // Get image properties
//            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
//                  let pixelWidth = properties[kCGImagePropertyPixelWidth] as? Int,
//                  let pixelHeight = properties[kCGImagePropertyPixelHeight] as? Int else {
//                return nil
//            }
//            
//            // Calculate scale factor
//            let maxDimension = await max(self.targetSize.width, self.targetSize.height) * UIScreen.main.scale
//            let scale = maxDimension / CGFloat(max(pixelWidth, pixelHeight))
//            
//            // Only downsample if image is larger than needed
//            if scale < 1.0 {
//                let downsampleOptions = [
//                    kCGImageSourceCreateThumbnailFromImageAlways: true,
//                    kCGImageSourceShouldCacheImmediately: true,
//                    kCGImageSourceCreateThumbnailWithTransform: true,
//                    kCGImageSourceThumbnailMaxPixelSize: maxDimension
//                ] as CFDictionary
//                
//                if let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) {
//                    return UIImage(cgImage: downsampledImage)
//                }
//            }
//            
//            // Return original image if downsampling not needed or failed
//            return UIImage(data: data)
//        }.value
//    }
    private func loadImage(from data: Data) async -> UIImage? {
        await Task.detached(priority: .userInitiated) {
            let imageSourceOptions = [
                kCGImageSourceShouldCache: false,
                kCGImageSourceShouldAllowFloat: false
            ] as CFDictionary
            
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
                return nil
            }
            
            // More aggressive downsampling
            let maxDimension = await min(self.targetSize.width, self.targetSize.height) * UIScreen.main.scale
            
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimension,
                kCGImageSourceShouldAllowFloat: false
            ] as CFDictionary
            
            if let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) {
                return UIImage(cgImage: downsampledImage)
            }
            
            return UIImage(data: data)
        }.value
    }
}
