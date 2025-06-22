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
                    
                    LabeledContent("Clear Image Cache") {
                        Button("Clear") {
                            ImageCache.default.clearCache()
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
