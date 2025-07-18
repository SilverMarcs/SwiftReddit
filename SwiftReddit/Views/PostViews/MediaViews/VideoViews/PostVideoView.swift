import SwiftUI
import AVKit

struct PostVideoView: View {
    @Environment(\.videoNS) private var videoNS
    @Namespace private var fallbackNS
    
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true
    
    let videoURL: String?
    let thumbnailURL: String?
    let dimensions: CGSize?

    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?

    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9, contentMode: .fit)
            .matchedGeometryEffect(id: videoURL ?? "videoPlayer", in: videoNS ?? fallbackNS)
//            .transition(.scale(scale: 1))
            .cornerRadius(12)
            .clipped()
            .onTapGesture {
                VideoOverlayViewModel.shared.present(player: player, videoURL: videoURL)
            }
            .task {
                await setupPlayer()
            }
            .onDisappear {
                cleanupPlayer()
            }
    }
    
    private func setupPlayer() async {
        guard let videoURL = videoURL,
              let url = URL(string: videoURL),
              player == nil else { return }
        
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredPeakBitRate = 2_000_000
        
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = muteOnPlay
        
        // Use AVPlayerLooper instead of notification
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        player = queuePlayer
        
        if autoplay {
            queuePlayer.play()
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        playerLooper?.disableLooping()
        playerLooper = nil
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
}
