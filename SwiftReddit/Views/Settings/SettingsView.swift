//
//  SettingsView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Reddit API") {
                    NavigationLink(destination: CredentialsView()) {
                        Label("Credentials", systemImage: "key.fill")
                    }
                }
                
            }
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
}

#Preview {
    SettingsView()
}
