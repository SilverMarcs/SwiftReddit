import SwiftUI

struct FullscreenImageOverlay: View {
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    var viewModel: ImageOverlayViewModel = .shared
    
    var body: some View {
        if viewModel.isPresented, !viewModel.images.isEmpty {
            if viewModel.images.count == 1, let singleImage = viewModel.images.first {
                SingleImageView(image: singleImage, namespace: imageNS ?? fallbackNS) {
                    viewModel.dismiss()
                }
            } else {
                MultipleImagesView(images: viewModel.images, namespace: imageNS ?? fallbackNS) {
                    viewModel.dismiss()
                }
            }
        }
    }
}




