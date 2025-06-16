//
//  AddCredentialView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct AddCredentialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var credentialsManager = CredentialsManager.shared
    @State private var appID = ""
    @State private var appSecret = ""
    @State private var isLoading = false
    @State private var waitingForCallback = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    private var isFormValid: Bool {
        !appID.trimmingCharacters(in: .whitespaces).isEmpty &&
        !appSecret.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reddit API Setup")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("To use Winston, you need to create your own Reddit API credentials. Don't worry - it's free and easy!")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                Section("Step 1: Get Your Credentials") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Go to Reddit's app preferences")
                        Text("2. Create a new app (select 'installed app')")
                        Text("3. Copy the App ID and Secret below")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Link(destination: URL(string: "https://www.reddit.com/prefs/apps")!) {
                        HStack {
                            Image(systemName: "safari")
                            Text("Open Reddit App Settings")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                Section("Step 2: Enter Your Credentials") {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("App ID")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Enter your Reddit app ID", text: $appID)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("App Secret")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Enter your Reddit app secret", text: $appSecret)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                    }
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
                                Button(action: authorizeCredential) {
                                    HStack {
                                        if isLoading {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "checkmark.shield")
                                        }
                                        Text("Authorize with Reddit")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .disabled(isLoading)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Credential")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {
                    showingError = false
                }
            } message: {
                Text(errorMessage)
            }
            .onOpenURL { url in
                handleRedirectURL(url)
            }
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
        
        let authURL = RedditAPI.shared.getAuthorizationCodeURL(trimmedAppID)
        waitingForCallback = true
        
        UIApplication.shared.open(authURL)
    }
    
    private func handleRedirectURL(_ url: URL) {
        guard waitingForCallback else { return }
        
        if let authCode = RedditAPI.shared.getAuthCodeFromURL(url) {
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
        
        let result = await RedditAPI.shared.injectFirstAccessTokenInto(credential, authCode: authCode)
        
        await MainActor.run {
            isLoading = false
            waitingForCallback = false
            
            if let updatedCredential = result {
                credentialsManager.saveCredential(updatedCredential)
                if credentialsManager.selectedCredential == nil {
                    credentialsManager.selectedCredential = updatedCredential
                }
                dismiss()
            } else {
                errorMessage = "Failed to exchange authorization code for access token. Please check your credentials and try again."
                showingError = true
            }
        }
    }
}

#Preview {
    AddCredentialView()
}
