//
//  ImageCacher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

// Actor for thread-safe memory cache
actor MemoryCache {
    static let shared = MemoryCache()
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
