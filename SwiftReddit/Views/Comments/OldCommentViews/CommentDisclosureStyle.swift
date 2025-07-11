//
//  CommentDisclosureStyle.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct CommentDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                configuration.label
            }
            .buttonStyle(.plain)
            .contentShape(.rect)
            .accessibilityHint(configuration.isExpanded ? "Tap to collapse replies" : "Tap to expand replies")
            
            // Children comments (content) with smooth animation
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}
