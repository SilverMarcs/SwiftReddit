//
//  ImageCacher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI
import UIKit

func clearAllCaches() async {
    // Clear memory cache
    await ImageCacher.shared.clearCache()
    
    // Clear disk cache
    DiskCache.shared.clearCache()
}


// Actor for thread-safe memory cache
actor ImageCacher {
    static let shared = ImageCacher()
    private var cache = NSCache<NSString, UIImage>()
    
    init() {
        cache.countLimit = 150
        // Add total cost limit (in bytes) to prevent excessive memory usage
        cache.totalCostLimit = 1024 * 1024 * 60 // 100 MB
    }
    
    func insert(_ image: UIImage, for key: String) {
        // Calculate approximate memory cost
        let bytesPerPixel = 4
        let imageSize = image.size
        let cost = Int(imageSize.width * imageSize.height * CGFloat(bytesPerPixel))
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func get(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
}

// Disk cache helper
struct DiskCache {
    static let shared = DiskCache()
    private let fileManager = FileManager.default
    
    private var cacheDirectory: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("ImageCacher")
    }
    
    init() {
        createCacheDirectoryIfNeeded()
    }
    
    private func createCacheDirectoryIfNeeded() {
        guard let cacheDirectory = cacheDirectory else { return }
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func store(_ data: Data, for key: String) {
        guard let cacheDirectory = cacheDirectory else { return }
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? data.write(to: fileURL)
    }
    
    func retrieve(for key: String) -> Data? {
        guard let cacheDirectory = cacheDirectory else { return nil }
        let fileURL = cacheDirectory.appendingPathComponent(key)
        return try? Data(contentsOf: fileURL)
    }
    
    func clearCache() {
        guard let cacheDirectory = cacheDirectory else { return }
        try? fileManager.removeItem(at: cacheDirectory)
        createCacheDirectoryIfNeeded()
    }
}

// Image loader with downsampling
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
            if let cachedImage = await ImageCacher.shared.get(for: cacheKey) {
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
                    await ImageCacher.shared.insert(finalImage, for: cacheKey)
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

// SwiftUI View
struct CachedImage<Placeholder: View>: View {
    private var loader: ImageLoader
    private var placeholder: Placeholder
    @State private var image: UIImage?
    
    init(url: URL,
         targetSize: CGSize,
         @ViewBuilder placeholder: () -> Placeholder) {
        self.loader = ImageLoader(url: url, targetSize: targetSize)
        self.placeholder = placeholder()
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
            }
        }
        .task {
            image = await loader.loadAndGetImage()
        }
    }
}
