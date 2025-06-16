//
//  SettingsView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Reddit API") {
                    NavigationLink(destination: CredentialsView()) {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.blue)
                            Text("Credentials")
                        }
                    }
                }
                
                Section("App") {
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(.orange)
                        Text("App Icon")
                        Spacer()
                        Text("Default")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
