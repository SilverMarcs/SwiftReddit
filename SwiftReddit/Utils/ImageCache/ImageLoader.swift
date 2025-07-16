//
//  ImageLoader.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

@Observable class ImageLoader {
    @ObservationIgnored private let url: URL
    @ObservationIgnored private let targetSize: CGSize
    @ObservationIgnored private var loadTask: Task<UIImage?, Never>?
    
    init(url: URL, targetSize: CGSize) {
        self.url = url
        self.targetSize = targetSize
    }
    
    func loadAndGetImage() async -> UIImage? {
        loadTask?.cancel()
        
        loadTask = Task {
            // Generate a cache key that includes the target size
            let sizeKey = "\(Int(targetSize.width))x\(Int(targetSize.height))"
            let cacheKey = "\(url.absoluteString)_\(sizeKey)"
            
            // Check memory cache first
            if let cachedImage = await MemoryCache.shared.get(for: cacheKey) {
                return cachedImage
            }
            
            // Efficient loading from disk or network
            do {
                let image: UIImage?
                
                // Check disk cache first
                if let diskData = DiskCache.shared.retrieve(for: url.absoluteString) {
                    image = await loadImage(from: diskData)
                } else {
                    // Download if not in disk cache
                    let (data, _) = try await URLSession.shared.data(from: url)
                    DiskCache.shared.store(data, for: url.absoluteString)
                    image = await loadImage(from: data)
                }
                
                if let finalImage = image {
                    await MemoryCache.shared.insert(finalImage, for: cacheKey)
                }
                
                return image
            } catch {
                print("Error loading image: \(error)")
                return nil
            }
        }
        
        return await loadTask?.value
    }
    
    private func loadImage(from data: Data) async -> UIImage? {
        await Task.detached(priority: .userInitiated) {
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
                return nil
            }
            
            // Get image properties
            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
                  let pixelWidth = properties[kCGImagePropertyPixelWidth] as? Int,
                  let pixelHeight = properties[kCGImagePropertyPixelHeight] as? Int else {
                return nil
            }
            
            // Calculate scale factor
            let maxDimension = await max(self.targetSize.width, self.targetSize.height) * UIScreen.main.scale
            let scale = maxDimension / CGFloat(max(pixelWidth, pixelHeight))
            
            // Only downsample if image is larger than needed
            if scale < 1.0 {
                let downsampleOptions = [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceShouldCacheImmediately: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: maxDimension
                ] as CFDictionary
                
                if let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) {
                    return UIImage(cgImage: downsampledImage)
                }
            }
            
            // Return original image if downsampling not needed or failed
            return UIImage(data: data)
        }.value
    }
}
