//
//  CredentialsView.swift
//  SwiftDdit
//
//  Created by SilverMarcs on 16/06/25.
//

import SwiftUI

struct CredentialsView: View {
    
    
    @State private var credentialsManager = CredentialsManager.shared
    @State private var appID = KeychainManager.shared.loadAppID() ?? ""
    @State private var isLoading = false
    @State private var waitingForCallback = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingDeleteAlert = false
    @State private var showingReplaceWarning = false
    @State private var credentialToDelete: RedditCredential?
    
    private var isFormValid: Bool {
        !appID.trimmingCharacters(in: .whitespaces).isEmpty
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
            
//            if !hasAnyCredentials && needsAppCredentials {
                Section("Step 1: Get Your App ID") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Go to Reddit's app preferences")
                        Text("2. Create a new app (select 'installed app')")
                        Text("3. Set the redirect URI to the following url:")
                        
                        HStack {
                            Text("swiftddit://auth-success")
                                .monospaced()
                            Spacer()
                            Button {
                                #if os(macOS)
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString("swiftddit://auth-success", forType: .string)
                                #else
                                UIPasteboard.general.string = "swiftddit://auth-success"
                                #endif
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                            .controlSize(.small)
                        }
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.background.tertiary)
                        }
                        
                        Text("4. Paste the App ID below")
                    }
                    .focusEffectDisabled()
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    Link(destination: URL(string: "https://www.reddit.com/prefs/apps")!) {
                        Label("Open Reddit App Settings", systemImage: "safari")
                    }
                    .environment(\.openURL, OpenURLAction { url in
                        return .systemAction
                    })
                }
                Section("Step 2: Enter Your App ID") {
                    TextField("Enter your Reddit app ID", text: $appID)
                        .onChange(of: appID) {
                            KeychainManager.shared.saveAppID(appID)
                        }
                }
            
                Section("Step 3: Add Account") {
                    Text("Click Plus button on top right and complete the auth flow in reddit website")
                }
//            }
        }
        .navigationTitle("Accounts")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isLoading || waitingForCallback {
                    Button("Cancel") {
                        cancelAuthorization()
                    }
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
            if let existingAppID = credentialsManager.existingAppCredentials {
                appID = existingAppID
            } else {
                appID = KeychainManager.shared.loadAppID() ?? ""
            }
        }
    }
    
    private func cancelAuthorization() {
        isLoading = false
        waitingForCallback = false
    }
    
    private func resetForm() {
        if !hasAnyCredentials {
            appID = ""
        }
    }
    
    private func authorizeCredential() {
        let trimmedAppID: String
        if let existingAppID = credentialsManager.existingAppCredentials {
            trimmedAppID = existingAppID
        } else {
            trimmedAppID = appID.trimmingCharacters(in: .whitespaces)
        }
        guard !trimmedAppID.isEmpty else {
            errorMessage = "Please enter your App ID"
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
        isLoading = true
        
        let trimmedAppID: String
        if let existingAppID = credentialsManager.existingAppCredentials {
            trimmedAppID = existingAppID
        } else {
            trimmedAppID = appID.trimmingCharacters(in: .whitespaces)
        }
        let credential = RedditCredential(
            apiAppID: trimmedAppID
        )
        let success = await credentialsManager.authorizeCredential(credential, authCode: authCode)
        
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

#Preview {
    NavigationStack {
        CredentialsView()
    }
}
