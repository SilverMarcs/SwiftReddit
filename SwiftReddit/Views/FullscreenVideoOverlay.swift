import SwiftUI
import AVKit

struct FullscreenVideoOverlay: View {
    @ObservedObject var viewModel: VideoOverlayViewModel = .shared
    
    var body: some View {
        if viewModel.isPresented, let player = viewModel.player {
            VideoPlayer(player: player)
                .ignoresSafeArea()
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
