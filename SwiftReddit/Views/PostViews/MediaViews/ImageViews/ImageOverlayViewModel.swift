import SwiftUI

@Observable class ImageOverlayViewModel {
    static let shared = ImageOverlayViewModel()
    var isPresented: Bool = false
    var images: [GalleryImage] = []
    var currentImageURL: String? = nil

    func present(images: [GalleryImage]) {
        self.currentImageURL = images.first?.url

        withAnimation(.easeInOut(duration: 0.2)) {
            self.images = images
            isPresented = true
        }
    }
    
    func dismiss() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPresented = false
        }
        
        self.images = []
        self.currentImageURL = nil
    }
}
