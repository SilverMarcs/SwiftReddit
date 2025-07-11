import SwiftUI

struct FullscreenImageOverlay: View {
    @Environment(\.imageZoomNamespace) private var imageZoomNamespace
    var viewModel: ImageOverlayViewModel = .shared
    
    var body: some View {
        if viewModel.isPresented, !viewModel.images.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(viewModel.images) { galleryImage in
                        ImageView(url: URL(string: galleryImage.url), aspectRatio: galleryImage.aspectRatio)
                            .matchedGeometryEffect(id: galleryImage.url, in: imageZoomNamespace)
                            .zoomable()
                            .frame(width: UIScreen.main.bounds.width)
                            .tag(galleryImage.id)
                    }
                }
            }
            .ignoresSafeArea()
            .background(.black)
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.height > 80 {
                            viewModel.dismiss()
                        }
                    }
            )
            // Enable paging behavior
            .scrollTargetBehavior(.paging)
        }
    }
}
