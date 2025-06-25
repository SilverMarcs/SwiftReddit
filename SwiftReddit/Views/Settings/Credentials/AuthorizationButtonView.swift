//
//  AuthorizationButtonView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

struct AuthorizationButtonView: View {
    let isLoading: Bool
    let waitingForCallback: Bool
    let onAuthorize: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if waitingForCallback {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Waiting for authorization...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                Button(action: onAuthorize) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Label("Authorize with Reddit", systemImage: "checkmark.shield")
                            .foregroundStyle(.primary)
                    }
                }
                .disabled(isLoading)
            }
        }
    }
}
