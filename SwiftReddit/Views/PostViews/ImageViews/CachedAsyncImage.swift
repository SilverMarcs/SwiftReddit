//
//  CachedAsyncImage.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 19/06/2025.
//

import SwiftUI

public struct CachedAsyncImage: View {
    var url: URL?
    var aspectRatio: CGFloat? = 1 // Default aspect ratio, can be adjusted as needed
    @State private var image: Image? = nil
    @State private var isLoading = false

    public var body: some View {
        if let image = image {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Rectangle()
                .fill(.background.secondary)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .overlay(
                    ProgressView()
                )
                .onAppear {
                    Task {
                        await loadImage()
                    }
                }
        }
    }

    private func loadImage() async {
        guard let url = url, !isLoading else { return }

        // Ensure state updates are isolated to the main actor
        isLoading = true

        // Check if the image is already cached
        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let cachedImage = UIImage(data: cachedResponse.data) {
            await MainActor.run {
                self.image = Image(uiImage: cachedImage)
                self.isLoading = false
            }
            return
        }

        // Fetch the image from the network
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Cache the image
            let cachedData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedData, for: request)

            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = Image(uiImage: uiImage)
                    self.isLoading = false
                }
            }
        } catch {
            // Handle any errors here (e.g., network failure)
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}
