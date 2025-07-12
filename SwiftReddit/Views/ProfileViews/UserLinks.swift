//
//  UserLinks.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct UserLinks: View {
    @Environment(Nav.self) var nav
    
    var body: some View {
        Section {
            HStack {
                LinkButton(
                    icon: "tray.circle.fill",
                    title: "Inbox",
                    iconColor: .blue
                ) {
                    nav.path.append(Destination.inbox)
                }
                
                LinkButton(
                    icon: "bookmark.circle.fill",
                    title: "Saved",
                    iconColor: .green
                ) {
                    nav.path.append(PostFeedType.saved)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
        }
    }
}

struct LinkButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundStyle(iconColor)
                    
                    Text(title)
                        .bold()
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.headline)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background.secondary)
        )
    }
}
