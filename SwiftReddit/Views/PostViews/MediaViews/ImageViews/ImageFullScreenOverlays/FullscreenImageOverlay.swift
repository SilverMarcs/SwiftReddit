import SwiftUI

struct FullscreenImageOverlay: View {
    @Environment(\.imageZoomNamespace) private var imageZoomNamespace
    var viewModel: ImageOverlayViewModel = .shared
    
    var body: some View {
        if viewModel.isPresented, !viewModel.images.isEmpty {
            if viewModel.images.count == 1, let singleImage = viewModel.images.first {
                SingleImageView(image: singleImage, namespace: imageZoomNamespace) {
                    viewModel.dismiss()
                }
            } else {
                MultipleImagesView(images: viewModel.images, namespace: imageZoomNamespace) {
                    viewModel.dismiss()
                }
            }
        }
    }
}




