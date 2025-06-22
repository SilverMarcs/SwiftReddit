//
//  ProfileView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 22/06/2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            Text("Profile View")
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
