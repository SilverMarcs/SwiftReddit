//
//  ProfileView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(Nav.self) private var nav
    @State var showSettings = false
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            UserSubredditsView()
                .navigationDestinations()
                .navigationTitle("Profile")
                .toolbarTitleDisplayMode(.inlineLarge)
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showSettings.toggle()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
        }
    }
}

#Preview {
    ProfileView()
}
