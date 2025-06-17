import SwiftUI
import AVKit

struct PostVideoView: View {
    let videoURL: String?
    let thumbnailURL: String?
    let dimensions: CGSize?
    
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .cornerRadius(12)
            .clipped()
            .aspectRatio(
                dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9,
                contentMode: .fit
            )
            .onAppear {
                if let videoURL = videoURL, let url = URL(string: videoURL) {
                    player = AVPlayer(url: url)
                    player?.isMuted = true // Start muted by default
                    player?.play()
                }
            }
            .onDisappear {
                player?.pause()
            }
    }
}
