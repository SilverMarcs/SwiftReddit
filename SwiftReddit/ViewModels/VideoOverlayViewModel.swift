import SwiftUI
import AVKit
import Combine

class VideoOverlayViewModel: ObservableObject {
    static let shared = VideoOverlayViewModel()
    @Published var isPresented: Bool = false
    @Published var player: AVPlayer? = nil
    var onDismiss: (() -> Void)?

    func present(player: AVPlayer?, onDismiss: (() -> Void)? = nil) {
        self.player = player
        self.onDismiss = onDismiss
        isPresented = true
    }
    func dismiss() {
        isPresented = false
        onDismiss?()
        onDismiss = nil
    }
}
