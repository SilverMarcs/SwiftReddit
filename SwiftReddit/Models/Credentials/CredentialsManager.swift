//
//  CredentialsManager.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import Foundation
import SwiftUI
import Combine

@Observable
class CredentialsManager {
    static let shared = CredentialsManager()
    
    private let userDefaults = UserDefaults.standard
    private let credentialsKey = "reddit_credential" // Changed to singular
    
    // Single credential instead of array
    var credential: RedditCredential? = nil
    
    // OAuth state management
    var lastAuthState: String?
    
    private init() {
        loadCredentials()
    }
    
    func saveCredential(_ newCredential: RedditCredential) {
        // Replace any existing credential with the new one
        credential = newCredential
        saveToUserDefaults()
    }
    
    func deleteCredential(_ credentialToDelete: RedditCredential) {
        // Only delete if it matches the current credential
        if credential?.id == credentialToDelete.id {
            credential = nil
            saveToUserDefaults()
        }
    }
    
    func deleteAllCredentials() {
        credential = nil
        saveToUserDefaults()
    }
    
    private func loadCredentials() {
        // Try to load single credential first
        if let data = userDefaults.data(forKey: credentialsKey),
           let loadedCredential = try? JSONDecoder().decode(RedditCredential.self, from: data) {
            self.credential = loadedCredential
            return
        }
        
        // Migration: Try to load from old multiple credentials format
        if let data = userDefaults.data(forKey: "reddit_credentials"),
           let loadedCredentials = try? JSONDecoder().decode([RedditCredential].self, from: data),
           let firstCredential = loadedCredentials.first {
            self.credential = firstCredential
            // Clear old format and save in new format
            userDefaults.removeObject(forKey: "reddit_credentials")
            userDefaults.removeObject(forKey: "selected_credential_id")
            saveToUserDefaults()
        }
    }
    
    private func saveToUserDefaults() {
        if let credential = credential,
           let data = try? JSONEncoder().encode(credential) {
            userDefaults.set(data, forKey: credentialsKey)
        } else {
            userDefaults.removeObject(forKey: credentialsKey)
        }
    }
    
    // MARK: - OAuth Flow Management
    
    func getAuthorizationCodeURL(_ appID: String) -> URL {
        let response_type: String = "code"
        let state: String = UUID().uuidString
        let redirect_uri: String = RedditAPI.appRedirectURI
        let duration: String = "permanent"
        let scope: String = "identity,edit,flair,history,modconfig,modflair,modlog,modposts,modwiki,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote,wikiedit,wikiread"
        
        lastAuthState = state
        
        let urlString = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(appID.trimmingCharacters(in: .whitespaces))&response_type=\(response_type)&state=\(state)&redirect_uri=\(redirect_uri)&duration=\(duration)&scope=\(scope)"
        
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    }
    
    func getAuthCodeFromURL(_ rawUrl: URL) -> String? {
        if let url = URL(string: rawUrl.absoluteString.replacingOccurrences(of: "winstonapp://", with: "https://app.winston.cafe/")),
           url.lastPathComponent == "auth-success",
           let query = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let state = query.queryItems?.first(where: { $0.name == "state" })?.value,
           let code = query.queryItems?.first(where: { $0.name == "code" })?.value,
           state == lastAuthState {
            return code
        }
        return nil
    }
    
    func authorizeCredential(_ credential: RedditCredential, authCode: String) async -> Bool {
        guard !credential.apiAppID.isEmpty && !credential.apiAppSecret.isEmpty else { return false }
        
        // Exchange auth code for tokens
        guard let tokenResponse = await RedditAPI.shared.exchangeAuthCodeForTokens(
            appID: credential.apiAppID,
            appSecret: credential.apiAppSecret,
            authCode: authCode
        ) else {
            return false
        }
        
        var updatedCredential = credential
        let newAccessToken = RedditCredential.AccessToken(
            token: tokenResponse.access_token,
            expiration: tokenResponse.expires_in,
            lastRefresh: Date()
        )
        
        updatedCredential.refreshToken = tokenResponse.refresh_token
        updatedCredential.accessToken = newAccessToken
        
        // Fetch user info
        if let userData = await RedditAPI.shared.fetchMe(
            with: tokenResponse.access_token,
            userAgent: "ios:lo.cafe.winston:v0.1.0 (by /u/UnknownUser)"
        ) {
            updatedCredential.userName = userData.name
            if let iconImg = userData.icon_img, !iconImg.isEmpty {
                updatedCredential.profilePicture = iconImg
            }
        }
        
        saveCredential(updatedCredential)
        return true
    }
    
    // MARK: - Token Management
    
    func getValidAccessToken() async -> String? {
        guard let credential = credential else { return nil }
        
        let result = await credential.getUpToDateToken()
        
        // Handle credential updates from token refresh
        if let updatedCredential = result.updatedCredential {
            saveCredential(updatedCredential)
        }
        
        return result.token?.token
    }
}
