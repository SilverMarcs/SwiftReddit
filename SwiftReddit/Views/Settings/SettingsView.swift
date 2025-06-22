//
//  SettingsView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI
import Kingfisher

struct SettingsView: View {
    @ObservedObject private var config = Config.shared
    @State private var deleteAlertPresented = false
    @State private var cacheSize: String = "Calculating..."
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reddit API") {
                    NavigationLink(destination: CredentialsView()) {
                        Label("Credentials", systemImage: "key.fill")
                    }
                }
                
                Section("Playback Settings") {
                    Toggle(isOn: $config.autoplay) {
                        Label("Autoplay Videos", systemImage: "play.fill")
                    }
                    Toggle(isOn: $config.muteOnPlay) {
                        Label("Mute on Play", systemImage: "speaker.slash.fill")
                    }
                }
                
                Section("Debug") {
                    Toggle(isOn: $config.printDebug) {
                        Label("Print Debug Info", systemImage: "terminal.fill")
                    }
                    
                    Button {
                        deleteAlertPresented = true
                    } label: {
                        HStack {
                            Label {
                                Text("Clear Image Cache")
                                
                            } icon: {
                                Image(systemName: "trash")
                            }
                            
                            Spacer()
                            
                            Text("\(cacheSize)")
                        }
                    }
                    .alert("Clear Image Cache", isPresented: $deleteAlertPresented) {
                        Button("Clear", role: .destructive) {
                            ImageCache.default.clearCache()
                            calculateCacheSize()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("This will clear all cached images, freeing up storage space.")
                    }
                }
            }
            .task {
                calculateCacheSize()
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
    
    private func calculateCacheSize() {
        ImageCache.default.calculateDiskStorageSize { result in
            Task { @MainActor in
                switch result {
                case .success(let size):
                    self.cacheSize = String(format: "%.2f MB", Double(size) / 1024 / 1024)
                case .failure:
                    self.cacheSize = "Unknown"
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
