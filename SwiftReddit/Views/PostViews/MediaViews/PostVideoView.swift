import SwiftUI
import AVKit

struct PostVideoView: View {
    @ObservedObject private var config = Config.shared
    let videoURL: String?
    let thumbnailURL: String?
    let dimensions: CGSize?
    
    @State private var player: AVPlayer?
    @State private var showingFullscreen = false
    
    var body: some View {
        VideoPlayer(player: player)
            .cornerRadius(12)
            .clipped()
            .aspectRatio(
                dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9,
                contentMode: .fit
            )
            .onTapGesture {
                showingFullscreen = true
            }
            .sheet(isPresented: $showingFullscreen) {
                VideoPlayer(player: player)
                    .ignoresSafeArea(edges: .bottom)
            }
            .task {
                if let videoURL = videoURL, let url = URL(string: videoURL) {
                    // Configure audio session to allow mixing with other audio
                    #if !os(macOS)
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch {
                        print("Failed to configure audio session: \(error)")
                    }
                    #endif
                    
                    let playerItem = AVPlayerItem(url: url)
                    playerItem.preferredPeakBitRate = 1_000_000
                    
                    player = AVPlayer(playerItem: playerItem)
                    player?.isMuted = config.muteOnPlay
                    
                    // Add observer for video loop
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: playerItem,
                        queue: .main
                    ) { _ in
                        player?.seek(to: .zero)
                        player?.play()
                    }
                    
                    if config.autoplay {
                        player?.play()
                    }
                }
            }
            .onDisappear {
                // Remove observer when view disappears
                if let playerItem = player?.currentItem {
                    NotificationCenter.default.removeObserver(
                        self,
                        name: .AVPlayerItemDidPlayToEndTime,
                        object: playerItem
                    )
                }
                player?.pause()
                player = nil
            }
    }
}
