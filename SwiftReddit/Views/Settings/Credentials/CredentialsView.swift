//
//  CredentialsView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct CredentialsView: View {
    @State private var credentialsManager = CredentialsManager.shared
    @State private var appID = ""
    @State private var appSecret = ""
    @State private var isLoading = false
    @State private var waitingForCallback = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingDeleteAlert = false
    @State private var showingReplaceWarning = false
    @State private var isAddingCredential = false
    
    private var isFormValid: Bool {
        !appID.trimmingCharacters(in: .whitespaces).isEmpty &&
        !appSecret.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var hasExistingCredential: Bool {
        credentialsManager.credential != nil
    }
    
    var body: some View {
        Form {
            if let credential = credentialsManager.credential {
                Section("Reddit Credential") {
                    HStack {
                        Label {
                            Text(credential.userName ?? "Unknown User")
                            Text(credential.apiAppID)
                        } icon: {
                            Image(systemName: "key.fill")
                                .foregroundStyle(credential.validationStatus.meta.color)
                        }
                        
                        Spacer()
                        
                        Button {
                            showingDeleteAlert = true
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        
            
            if !hasExistingCredential || isAddingCredential {
                Section("Step 1: Get Your Credentials") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Go to Reddit's app preferences")
                        Text("2. Create a new app (select 'installed app')")
                        Text("3. Copy the App ID and Secret below")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    Link(destination: URL(string: "https://www.reddit.com/prefs/apps")!) {
                        Label("Open Reddit App Settings", systemImage: "safari")
                    }
                }
                
                Section("Step 2: Enter Your Credentials") {
                    TextField("Enter your Reddit app ID", text: $appID)
                        
                    TextField("Enter your Reddit app secret", text: $appSecret)
                }
                
                if isFormValid {
                    Section("Step 3: Authorize") {
                        VStack(spacing: 12) {
                            if waitingForCallback {
                                VStack(spacing: 8) {
                                    ProgressView()
                                    Text("Waiting for authorization...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            } else {
                                Button(action: {
                                    if hasExistingCredential {
                                        showingReplaceWarning = true
                                    } else {
                                        authorizeCredential()
                                    }
                                }) {
                                    if isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "checkmark.shield")
                                    }
                                    
                                    Text(hasExistingCredential ? "Replace & Authorize" : "Authorize with Reddit")
                                }
                                .disabled(isLoading)
                            }
                        }
                    }
                }
            } else {
                // Show button to start adding credential
                Section {
                    Button(hasExistingCredential ? "Replace Credential" : "Add Credential") {
                        isAddingCredential = true
                    }
                }
            }
        }
        .navigationTitle("Reddit Credential")
        .toolbarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showingError) {
            Button("OK") {
                showingError = false
            }
        } message: {
            Text(errorMessage)
        }
        .alert("Replace Credential", isPresented: $showingReplaceWarning) {
            Button("Cancel", role: .cancel) {
                showingReplaceWarning = false
            }
            Button("Replace", role: .destructive) {
                showingReplaceWarning = false
                authorizeCredential()
            }
        } message: {
            Text("This will replace your existing Reddit credential. Are you sure you want to continue?")
        }
        .alert("Delete Credential", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showingDeleteAlert = false
            }
            Button("Delete", role: .destructive) {
                credentialsManager.deleteCredential(credentialsManager.credential!)
                showingDeleteAlert = false
                // Reset form state
                appID = ""
                appSecret = ""
                isAddingCredential = false
            }
        } message: {
            Text("Are you sure you want to delete this credential? This action cannot be undone.")
        }
        .onOpenURL { url in
            handleRedirectURL(url)
        }
    }
    
    private func authorizeCredential() {
        let trimmedAppID = appID.trimmingCharacters(in: .whitespaces)
        let trimmedAppSecret = appSecret.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedAppID.isEmpty && !trimmedAppSecret.isEmpty else {
            errorMessage = "Please enter both App ID and App Secret"
            showingError = true
            return
        }
        
        let authURL = credentialsManager.getAuthorizationCodeURL(trimmedAppID)
        waitingForCallback = true
        
        #if os(macOS)
        NSWorkspace.shared.open(authURL)
        #else
        UIApplication.shared.open(authURL)
        #endif
    }
    
    private func handleRedirectURL(_ url: URL) {
        guard waitingForCallback else { return }
        
        if let authCode = credentialsManager.getAuthCodeFromURL(url) {
            Task {
                await processAuthCode(authCode)
            }
        } else {
            waitingForCallback = false
            errorMessage = "Authorization was cancelled or failed"
            showingError = true
        }
    }
    
    private func processAuthCode(_ authCode: String) async {
        await MainActor.run {
            isLoading = true
        }
        
        let credential = RedditCredential(
            apiAppID: appID.trimmingCharacters(in: .whitespaces),
            apiAppSecret: appSecret.trimmingCharacters(in: .whitespaces)
        )
        
        let success = await credentialsManager.authorizeCredential(credential, authCode: authCode)
        
        await MainActor.run {
            isLoading = false
            waitingForCallback = false
            
            if success {
                // Reset form state
                appID = ""
                appSecret = ""
                isAddingCredential = false
            } else {
                errorMessage = "Failed to exchange authorization code for access token. Please check your credentials and try again."
                showingError = true
            }
        }
    }
}


#Preview {
    NavigationView {
        CredentialsView()
    }
}
