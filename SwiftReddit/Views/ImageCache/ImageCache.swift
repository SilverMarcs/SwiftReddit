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
        // Set only count limit instead of cost
        cache.countLimit = 150
    }
    
    func insert(_ image: UIImage, for key: String) {
        // Simple insert without cost calculation
        cache.setObject(image, forKey: key as NSString)
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
            // Check memory cache first
            if let cachedImage = await ImageCacher.shared.get(for: url.absoluteString) {
                return cachedImage
            }
            
            // Check disk cache and downsample
            if let diskData = DiskCache.shared.retrieve(for: url.absoluteString),
               let diskImage = UIImage(data: diskData) {
                let downsampledImage = await downsample(image: diskImage)
                await ImageCacher.shared.insert(downsampledImage, for: url.absoluteString)
                return downsampledImage
            }
            
            // Download and downsample
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let downloadedImage = UIImage(data: data) else { return nil }
                
                let downsampledImage = await downsample(image: downloadedImage)
                
                // Store downsampled image in memory cache
                await ImageCacher.shared.insert(downsampledImage, for: url.absoluteString)
                
                // Store original data in disk cache
                // This allows for different target sizes in the future if needed
                DiskCache.shared.store(data, for: url.absoluteString)
                
                return downsampledImage
            } catch {
                print("Error loading image: \(error)")
                return nil
            }
        }
        
        return await loadTask?.value
    }
    
    private func downsample(image: UIImage) async -> UIImage {
        await Task.detached(priority: .userInitiated) {
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageData = image.jpegData(compressionQuality: 0.7) ?? image.pngData(), // Try JPEG first
                  let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
                return image
            }
            
            let maxDimensionInPixels = await max(self.targetSize.width, self.targetSize.height) * UIScreen.main.scale
            
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary
            
            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
                return image
            }
            
            return UIImage(cgImage: downsampledImage)
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
