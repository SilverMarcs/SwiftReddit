import SwiftUI
import AVKit

@Observable class VideoOverlayViewModel {
    static let shared = VideoOverlayViewModel()
    var isPresented: Bool = false
    var player: AVPlayer? = nil
    var currentVideoURL: String? = nil

    func present(player: AVPlayer?, videoURL: String?) {
        self.player = player
        self.currentVideoURL = videoURL

        withAnimation(.easeInOut(duration: 0.2)) {
            isPresented = true
        }
    }
    
    func dismiss() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPresented = false
        }
        
        self.player = nil
        self.currentVideoURL = nil
    }
}
