import SwiftUI
import AVKit

//struct FullscreenVideoOverlay: View {
//    var viewModel: VideoOverlayViewModel = .shared
//    
//    var body: some View {
//        if viewModel.isPresented, let player = viewModel.player {
//            VideoPlayer(player: player)
//                .ignoresSafeArea()
//                .gesture(
//                    DragGesture(minimumDistance: 30)
//                        .onEnded { value in
//                            if value.translation.height > 70 {
//                                viewModel.dismiss()
//                            }
//                        }
//                )
//        }
//    }
//}


struct FullscreenVideoOverlay: View {
    @Environment(\.videoNS) private var videoNS
    @Namespace private var fallbackNS
    
    var viewModel: VideoOverlayViewModel = .shared
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        if viewModel.isPresented, let player = viewModel.player {
            ZStack {
                // Fixed black background
                Color.black
                    .ignoresSafeArea()
                
                // Draggable VideoPlayer
                VideoPlayer(player: player)
                    .matchedGeometryEffect(id: viewModel.currentVideoURL ?? "videoPlayer", in: videoNS ?? fallbackNS)
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                // Only allow downward dragging
                                if value.translation.height > 0 {
                                    dragOffset = value.translation
                                }
                            }
                            .onEnded { value in
                                isDragging = false
                                
                                // If dragged down more than 100 points, dismiss
                                if value.translation.height > 70 {
                                    dismissVideo()
                                } else {
                                    // Spring back to original position
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
            }
            .onChange(of: viewModel.isPresented) { oldValue, newValue in
                if !newValue {
                    dragOffset = .zero
                }
            }
        }
    }
    
    private func dismissVideo() {
        withAnimation(.easeInOut(duration: 0.4)) {
            dragOffset = .zero
            viewModel.dismiss()
        }
    }
}
