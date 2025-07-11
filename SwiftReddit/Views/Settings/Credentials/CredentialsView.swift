//
//  CredentialsView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct CredentialsView: View {
    @State private var credentialsManager = CredentialsManager.shared
    @State private var appID = KeychainManager.shared.loadAppID() ?? ""
    @State private var appSecret = KeychainManager.shared.loadAppSecret() ?? ""
    @State private var isLoading = false
    @State private var waitingForCallback = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingDeleteAlert = false
    @State private var showingReplaceWarning = false
    @State private var credentialToDelete: RedditCredential?
    
    private var isFormValid: Bool {
        !appID.trimmingCharacters(in: .whitespaces).isEmpty &&
        !appSecret.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var hasAnyCredentials: Bool {
        !credentialsManager.credentials.isEmpty
    }
    
    private var needsAppCredentials: Bool {
        !hasAnyCredentials
    }
    
    var body: some View {
        List {
            if hasAnyCredentials {
                Section("Reddit Accounts") {
                    ForEach(credentialsManager.credentials) { credential in
                        AccountRowView(credential: credential)
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            credentialToDelete = credentialsManager.credentials[index]
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            
            // Show credential setup form for first account only
            if !hasAnyCredentials {
                if needsAppCredentials {
                    // Only show app credentials form if we don't have any existing credentials
                    Section("Step 1: Get Your App Credentials") {
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
                    
                    Section("Step 2: Enter Your App Credentials") {
                        TextField("Enter your Reddit app ID", text: $appID)
                            .onChange(of: appID) {
                                KeychainManager.shared.saveAppID(appID)
                            }
                        TextField("Enter your Reddit app secret", text: $appSecret)
                            .onChange(of: appSecret) {
                                KeychainManager.shared.saveAppSecret(appSecret)
                            }
                    }
                }
            }
        }
        .navigationTitle("Accounts")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isLoading || waitingForCallback {
                    ProgressView()
                } else {
                    Button {
                        authorizeCredential()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { showingError = false }
        } message: {
            Text(errorMessage)
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showingDeleteAlert = false
                credentialToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let credential = credentialToDelete {
                    credentialsManager.deleteCredential(credential)
                }
                showingDeleteAlert = false
                credentialToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this account? This action cannot be undone.")
        }
        .onOpenURL { url in
            handleRedirectURL(url)
        }
        .onAppear {
            // Pre-populate app credentials if we have existing accounts
            if let existingCreds = credentialsManager.existingAppCredentials {
                appID = existingCreds.appID
                appSecret = existingCreds.appSecret
            } else {
                appID = KeychainManager.shared.loadAppID() ?? ""
                appSecret = KeychainManager.shared.loadAppSecret() ?? ""
            }
        }
    }
    
    private func resetForm() {
        if !hasAnyCredentials {
            appID = ""
            appSecret = ""
        }
    }
    
    private func authorizeCredential() {
        let trimmedAppID: String
        let trimmedAppSecret: String
        
        // Use existing app credentials if available, otherwise use form input
        if let existingCreds = credentialsManager.existingAppCredentials {
            trimmedAppID = existingCreds.appID
            trimmedAppSecret = existingCreds.appSecret
        } else {
            trimmedAppID = appID.trimmingCharacters(in: .whitespaces)
            trimmedAppSecret = appSecret.trimmingCharacters(in: .whitespaces)
        }
        
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
        
        let trimmedAppID: String
        let trimmedAppSecret: String
        
        // Use existing app credentials if available, otherwise use form input
        if let existingCreds = credentialsManager.existingAppCredentials {
            trimmedAppID = existingCreds.appID
            trimmedAppSecret = existingCreds.appSecret
        } else {
            trimmedAppID = appID.trimmingCharacters(in: .whitespaces)
            trimmedAppSecret = appSecret.trimmingCharacters(in: .whitespaces)
        }
        
        let credential = RedditCredential(
            apiAppID: trimmedAppID,
            apiAppSecret: trimmedAppSecret
        )
        
        let success = await credentialsManager.authorizeCredential(credential, authCode: authCode)
        
        await MainActor.run {
            isLoading = false
            waitingForCallback = false
            
            if success {
                // Reset form state
                resetForm()
            } else {
                errorMessage = "Failed to exchange authorization code for access token. Please check your credentials and try again."
                showingError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        CredentialsView()
    }
}
