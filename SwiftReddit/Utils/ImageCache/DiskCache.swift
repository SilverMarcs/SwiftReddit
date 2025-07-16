//
//  DiskCache.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/07/2025.
//

import Foundation

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
