//
//  Created by Lorenzo Fiamingo on 04/11/20.
//

import SwiftUI

//extension URLCache {
//    static let imageCache = URLCache(memoryCapacity: 50_000_000, diskCapacity: 300_000_000)
//}

private let IMAGE_SIZE_LIMIT: Int = 2 * 1024 * 1024  // 2MB in bytes

private func downsampleImage(data: Data) throws -> Data {
    #if os(macOS)
    guard let sourceImage = NSImage(data: data) else {
        throw LoadingError.invalidImage
    }
    let targetSize = calculateTargetSize(sourceImage.size)
    guard let resizedImage = sourceImage.resize(to: targetSize),
          let downsampledData = resizedImage.tiffRepresentation else {
        throw LoadingError.invalidImage
    }
    #else
    guard let sourceImage = UIImage(data: data) else {
        throw LoadingError.invalidImage
    }
    let targetSize = calculateTargetSize(sourceImage.size)
    UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
    sourceImage.draw(in: CGRect(origin: .zero, size: targetSize))
    guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
        throw LoadingError.invalidImage
    }
    UIGraphicsEndImageContext()
    guard let downsampledData = resizedImage.jpegData(compressionQuality: 0.7) else {
        throw LoadingError.invalidImage
    }
    #endif
    
    return downsampledData
}

private func calculateTargetSize(_ originalSize: CGSize) -> CGSize {
    // This is a simple scaling algorithm. You might want to make it more sophisticated
//    let aspectRatio = originalSize.width / originalSize.height
    let scale = sqrt(Double(IMAGE_SIZE_LIMIT) / Double(originalSize.width * originalSize.height))
    let newWidth = originalSize.width * scale
    let newHeight = originalSize.height * scale
    return CGSize(width: newWidth, height: newHeight)
}

final class OversizedImageTracker {
    static var shared = OversizedImageTracker()
    init() {} // TODO: please dont call it manually. we need public init so that we can delete the singleton instance in settings
    
    private var oversizedURLs: Set<URL> = Set()
    
    func isOversized(_ url: URL) -> Bool {
        oversizedURLs.contains(url)
    }
    
    func markAsOversized(_ url: URL) {
        oversizedURLs.insert(url)
    }
}

private enum LoadingError: Error {
    case invalidImage
    case oversizedImage
}

public struct CachedAsyncImage<Content>: View where Content: View {
    @State private var phase: AsyncImagePhase
    private let urlRequest: URLRequest?
    private let urlSession: URLSession
    private let content: (AsyncImagePhase) -> Content
    
    public var body: some View {
        content(phase)
            .task(id: urlRequest, load)
    }
    
    public init(url: URL?, urlCache: URLCache = .shared) where Content == Image {
        let urlRequest = url == nil ? nil : URLRequest(url: url!)
        self.init(urlRequest: urlRequest, urlCache: urlCache)
    }
    
    public init(urlRequest: URLRequest?, urlCache: URLCache = .shared) where Content == Image {
        self.init(urlRequest: urlRequest, urlCache: urlCache) { phase in
            #if os(macOS)
            phase.image ?? Image(nsImage: .init())
            #else
            phase.image ?? Image(uiImage: .init())
            #endif
        }
    }
    
    public init<I, P>(url: URL?, urlCache: URLCache = .shared, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I : View, P : View {
        let urlRequest = url == nil ? nil : URLRequest(url: url!)
        self.init(urlRequest: urlRequest, urlCache: urlCache, content: content, placeholder: placeholder)
    }
    
    public init<I, P>(urlRequest: URLRequest?, urlCache: URLCache = .shared, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I : View, P : View {
        self.init(urlRequest: urlRequest, urlCache: urlCache) { phase in
            if let image = phase.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }
    
    public init(url: URL?, urlCache: URLCache = .shared, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        let urlRequest = url == nil ? nil : URLRequest(url: url!)
        self.init(urlRequest: urlRequest, urlCache: urlCache, content: content)
    }
    
    public init(urlRequest: URLRequest?, urlCache: URLCache = .shared, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        self.urlRequest = urlRequest
        self.urlSession = URLSession(configuration: configuration)
        self.content = content
        
        self._phase = State(wrappedValue: .empty)
        
        if let urlRequest = urlRequest,
           let url = urlRequest.url,
           OversizedImageTracker.shared.isOversized(url) {
            self._phase = State(wrappedValue: .failure(LoadingError.oversizedImage))
            return
        }
        
        do {
            if let urlRequest = urlRequest,
               let image = try cachedImage(from: urlRequest, cache: urlCache) {
                self._phase = State(wrappedValue: .success(image))
            }
        } catch {
            self._phase = State(wrappedValue: .failure(error))
        }
    }
    
    @Sendable
    private func load() async {
        do {
            if let urlRequest = urlRequest {
                let (image, metrics) = try await remoteImage(from: urlRequest, session: urlSession)
                phase = .success(image)
            } else {
                phase = .empty
            }
        } catch {
            phase = .failure(error)
        }
    }
    
    private func remoteImage(from request: URLRequest, session: URLSession) async throws -> (Image, URLSessionTaskMetrics) {
        if let url = request.url,
           OversizedImageTracker.shared.isOversized(url) {
            throw LoadingError.oversizedImage
        }
        
        let (data, response, metrics) = try await session.data(for: request)
        
        var processedData: Data = data
        if data.count > IMAGE_SIZE_LIMIT {
            print("Image data size exceeds limit: \(data.count) bytes, attempting to downsample.")
            try autoreleasepool {
                do {
                    // Try to downsample the image
                    processedData = try downsampleImage(data: data)
                    
                    // Store downsampled version in cache
                    if let url = request.url {
                        let cachedResponse = CachedURLResponse(
                            response: response,
                            data: processedData,
                            userInfo: nil,
                            storagePolicy: .allowed
                        )
                        session.configuration.urlCache?.storeCachedResponse(cachedResponse, for: request)
                    }
                } catch {
                    // If downsampling fails, mark as oversized and throw
                    if let url = request.url {
                        OversizedImageTracker.shared.markAsOversized(url)
                        session.configuration.urlCache?.removeCachedResponse(for: request)
                    }
                    throw LoadingError.oversizedImage
                }
            }
        }
        
        return (try image(from: processedData), metrics)
    }
    
    private func cachedImage(from request: URLRequest, cache: URLCache) throws -> Image? {
        if let url = request.url,
           OversizedImageTracker.shared.isOversized(url) {
            throw LoadingError.oversizedImage
        }
        
        guard let cachedResponse = cache.cachedResponse(for: request) else { return nil }
        
        if cachedResponse.data.count > IMAGE_SIZE_LIMIT {
            if let url = request.url {
                OversizedImageTracker.shared.markAsOversized(url)
                // Purge the oversized image from cache
                cache.removeCachedResponse(for: request)
            }
            throw LoadingError.oversizedImage
        }
        
        return try image(from: cachedResponse.data)
    }
    
    private func image(from data: Data) throws -> Image {
        #if os(macOS)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        } else {
            throw LoadingError.invalidImage
        }
        #else
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            throw LoadingError.invalidImage
        }
        #endif
    }
}

private class URLSessionTaskController: NSObject, URLSessionTaskDelegate {
    var metrics: URLSessionTaskMetrics?
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        self.metrics = metrics
    }
}

private extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse, URLSessionTaskMetrics) {
        let controller = URLSessionTaskController()
        let (data, response) = try await data(for: request, delegate: controller)
        return (data, response, controller.metrics!)
    }
}
