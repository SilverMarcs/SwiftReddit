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
            .task {
                if let videoURL = videoURL, let url = URL(string: videoURL) {
                    let playerItem = AVPlayerItem(url: url)
                    playerItem.preferredPeakBitRate = 1_000_000
                    
                    player = AVPlayer(playerItem: playerItem)
                    player?.isMuted = true
                    player?.play()
                }
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
    }
}
