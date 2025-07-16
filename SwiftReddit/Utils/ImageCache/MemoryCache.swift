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
    
    #if os(macOS)
    private var cache = NSCache<NSString, NSImage>()
    #else
    private var cache = NSCache<NSString, UIImage>()
    #endif
    
    init() {
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 50 // 50 MB
    }
    
    #if os(macOS)
    func insert(_ image: NSImage, for key: String) {
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func get(for key: String) -> NSImage? {
        cache.object(forKey: key as NSString)
    }
    #else
    func insert(_ image: UIImage, for key: String) {
        let bytesPerPixel = 4
        let imageSize = image.size
        let cost = Int(imageSize.width * imageSize.height * CGFloat(bytesPerPixel))
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func get(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    #endif
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
