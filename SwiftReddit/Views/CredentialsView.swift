//
//  CredentialsView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct CredentialsView: View {
    @State private var credentialsManager = CredentialsManager.shared
    @State private var showingAddCredential = false
    @State private var showingDeleteAlert = false
    @State private var credentialToDelete: RedditCredential?
    
    var body: some View {
        List {
            if credentialsManager.credentials.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "key.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Credentials")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add your Reddit API credentials to get started")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add Credential") {
                            showingAddCredential = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                Section("Reddit Credentials") {
                    ForEach(credentialsManager.credentials) { credential in
                        CredentialRowView(credential: credential)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    credentialToDelete = credential
                                    showingDeleteAlert = true
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("Credentials")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    showingAddCredential = true
                }
            }
        }
        .sheet(isPresented: $showingAddCredential) {
            AddCredentialView()
        }
        .alert("Delete Credential", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                credentialToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let credential = credentialToDelete {
                    credentialsManager.deleteCredential(credential)
                }
                credentialToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this credential? This action cannot be undone.")
        }
    }
}

struct CredentialRowView: View {
    let credential: RedditCredential
    @State private var credentialsManager = CredentialsManager.shared
    
    var isSelected: Bool {
        credentialsManager.selectedCredential?.id == credential.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let userName = credential.userName {
                        Text("u/\(userName)")
                            .font(.headline)
                    } else {
                        Text("Unnamed Credential")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("App ID: \(credential.apiAppID.prefix(12))...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: credential.validationStatus)
                    
                    if isSelected {
                        Text("Selected")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if credential.validationStatus == .authorized {
                credentialsManager.selectedCredential = credential
            }
        }
    }
}

struct StatusBadge: View {
    let status: RedditCredential.CredentialValidationState
    
    var body: some View {
        let meta = status.getMeta()
        
        Text(meta.label)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch status.getMeta().color {
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }
}

#Preview {
    NavigationView {
        CredentialsView()
    }
}
