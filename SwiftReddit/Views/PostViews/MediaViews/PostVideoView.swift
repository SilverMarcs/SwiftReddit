import SwiftUI
import AVKit

struct PostVideoView: View {
    @ObservedObject private var config = Config.shared
    let videoURL: String?
    let thumbnailURL: String?
    let dimensions: CGSize?

    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?

    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9, contentMode: .fit)
            .cornerRadius(12)
            .clipped()
            .onTapGesture {
                VideoOverlayViewModel.shared.present(player: player) {}
            }
            .task(id: videoURL) {
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
        
        do {
            #if !os(macOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            playerItem.preferredPeakBitRate = 2_000_000
            
            let queuePlayer = AVQueuePlayer(playerItem: playerItem)
            queuePlayer.isMuted = config.muteOnPlay
            
            // Use AVPlayerLooper instead of notification
            playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            player = queuePlayer
            
            if config.autoplay {
                queuePlayer.play()
            }
        } catch {
            print("Failed to setup video player: \(error)")
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
