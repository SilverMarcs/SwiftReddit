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
                    
                    Button(role: .destructive) {
                        deleteAlertPresented = true
                    } label: {
                        Label("Clear Image Cache", systemImage: "trash")
                    }
                    .alert("Clear Image Cache", isPresented: $deleteAlertPresented) {
                        Button("Clear", role: .destructive) {
                            ImageCache.default.clearCache()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("This will clear all cached images, freeing up storage space.")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
}

#Preview {
    SettingsView()
}
