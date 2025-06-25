//
//  AccountRowView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

struct AccountRowView: View {
    let credential: RedditCredential
    let isActive: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(credential.userName ?? "Unknown User")
                        .font(.headline)
                    
                    if isActive {
                        Text("Active")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                
                HStack {
                    Image(systemName: "key.fill")
                        .foregroundStyle(credential.validationStatus.meta.color)
                        .font(.caption)
                    
                    Text(credential.validationStatus.meta.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundStyle(.red)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isActive {
                onSelect()
            }
        }
    }
}
