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
    @State private var credentialToDelete: RedditCredential?
    
    private var isFormValid: Bool {
        !appID.trimmingCharacters(in: .whitespaces).isEmpty &&
        !appSecret.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var hasAnyCredentials: Bool {
        !credentialsManager.credentials.isEmpty
    }
    
    private var needsAppCredentials: Bool {
        !hasAnyCredentials && (appID.isEmpty || appSecret.isEmpty)
    }
    
    var body: some View {
        Form {
            // Show existing accounts
            if hasAnyCredentials {
                Section("Reddit Accounts") {
                    ForEach(credentialsManager.credentials) { credential in
                        AccountRowView(
                            credential: credential,
                            isActive: credentialsManager.activeCredentialId == credential.id,
                            onSelect: {
                                credentialsManager.setActiveCredential(credential.id)
                            },
                            onDelete: {
                                credentialToDelete = credential
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
                
                // Add new account section
                Section {
                    Button("Add Another Account") {
                        isAddingCredential = true
                    }
                    .disabled(isLoading || waitingForCallback)
                }
            }
            
            // Show credential setup form for first account or when adding new account
            if !hasAnyCredentials || isAddingCredential {
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
                        TextField("Enter your Reddit app secret", text: $appSecret)
                    }
                }
                
                // Authorization section
                if !needsAppCredentials {
                    Section(hasAnyCredentials ? "Authorize New Account" : "Step 3: Authorize") {
                        AuthorizationButtonView(
                            isLoading: isLoading,
                            waitingForCallback: waitingForCallback,
                            onAuthorize: authorizeCredential
                        )
                    }
                }
                
                // Cancel button when adding new account
                if isAddingCredential {
                    Section {
                        Button("Cancel") {
                            isAddingCredential = false
                            resetForm()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Accounts")
        .toolbarTitleDisplayMode(.inline)
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
                if isAddingCredential && !hasAnyCredentials {
                    isAddingCredential = false
                }
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
                isAddingCredential = false
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
