import SwiftUI
import AVKit

struct FullscreenVideoOverlay: View {
    @Environment(\.videoNS) private var videoNS
    var viewModel: VideoOverlayViewModel = .shared
    
    var body: some View {
        if viewModel.isPresented, let player = viewModel.player {
            VideoPlayer(player: player)
                .matchedGeometryEffect(id: viewModel.currentVideoURL ?? "videoPlayer", in: videoNS)
//                .transition(.scale(scale: 1))  
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
        }
    }
}
