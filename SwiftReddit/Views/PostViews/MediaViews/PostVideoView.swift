import SwiftUI
import AVKit

struct PostVideoView: View {
    @ObservedObject private var config = Config.shared
    let videoURL: String?
    let thumbnailURL: String?
    let dimensions: CGSize?
    
    @State private var player: AVPlayer?
    @State private var showingFullscreen = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    
    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(
                dimensions != nil ? (dimensions!.width / dimensions!.height) : 16/9,
                contentMode: .fit
            )
            .overlay(alignment: .bottom) {
                if duration > 0 {
                    ProgressView(value: max(0, min(currentTime, duration)), total: duration)
                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 9)
                        .padding(.bottom, 1)
                }
            }
            .cornerRadius(12)
            .clipped()
            .onTapGesture {
                var transaction = Transaction()
               transaction.disablesAnimations = true
               withTransaction(transaction) {
                   showingFullscreen = true
               }
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
                    
                    // Get video duration
                    if let duration = try? await playerItem.asset.load(.duration) {
                        self.duration = CMTimeGetSeconds(duration)
                    }
                    
                    // Add time observer for progress tracking
                    let timeInterval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                    player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { time in
                        currentTime = CMTimeGetSeconds(time)
                    }
                    
                    // Add observer for video loop
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: playerItem,
                        queue: .main
                    ) { _ in
                        player?.seek(to: .zero)
                        player?.play()
                        currentTime = 0
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
