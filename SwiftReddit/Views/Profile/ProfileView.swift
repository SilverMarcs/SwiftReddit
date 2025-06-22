//
//  ProfileView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 22/06/2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSettings = false
    @Environment(Nav.self) var nav
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        SavedPostsList()
                    } label: {
                        Label("Saved Posts", systemImage: "bookmark")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Profile")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    }
                }
            }
        }
    }
}
