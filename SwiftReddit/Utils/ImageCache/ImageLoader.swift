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
    private var loadTask: Task<PlatformImage?, Never>?
    
    init(url: URL, targetSize: CGSize) {
        self.url = url
        self.targetSize = targetSize
    }
    
    #if os(macOS)
    typealias PlatformImage = NSImage
    #else
    typealias PlatformImage = UIImage
    #endif
    
    func loadAndGetImage() async throws -> PlatformImage {
        loadTask?.cancel()
        
        return try await Task {
            let sizeKey = "\(Int(targetSize.width))x\(Int(targetSize.height))"
            let cacheKey = "\(url.absoluteString)_\(sizeKey)"
            
            if let cachedImage = await MemoryCache.shared.get(for: cacheKey) {
                return cachedImage
            }
            
            do {
                let image: PlatformImage?
                
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
    
    private func loadImage(from data: Data) async -> PlatformImage? {
        await Task.detached(priority: .userInitiated) {
            let imageSourceOptions = [
                kCGImageSourceShouldCache: false,
                kCGImageSourceShouldAllowFloat: false
            ] as CFDictionary
            
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
                return nil
            }
            
            let maxDimension = min(self.targetSize.width, self.targetSize.height) * 2
            
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: false,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimension,
                kCGImageSourceShouldAllowFloat: false
            ] as CFDictionary
            
            if let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) {
                #if os(macOS)
                return NSImage(cgImage: downsampledImage, size: NSSize(width: maxDimension, height: maxDimension))
                #else
                return UIImage(cgImage: downsampledImage, scale: 1.0, orientation: .up)
                #endif
            }
            
            #if os(macOS)
            return NSImage(data: data)
            #else
            return UIImage(data: data, scale: 1.0)
            #endif
        }.value
    }
}
