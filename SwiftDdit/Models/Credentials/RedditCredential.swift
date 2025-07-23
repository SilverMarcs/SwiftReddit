//
//  RedditCredential.swift
//  SwiftDdit
//
//  Created by SilverMarcs Team on 16/06/25.
//

import Foundation
import SwiftUI

struct RedditCredential: Identifiable, Equatable, Hashable, Codable {
    var id: UUID
    var apiAppID: String {
        willSet {
            if apiAppID != newValue {
                clearIdentity()
            }
        }
    }
    var accessToken: AccessToken? = nil
    var refreshToken: String? = nil
    var userName: String? = nil
    var profilePicture: String? = nil
    
    var validationStatus: CredentialValidationState {
        var newRedditAPIPairState: CredentialValidationState = .empty
        if self.apiAppID.count == 14 { // Reddit installed app IDs are 14 chars
            newRedditAPIPairState = .valid
        } else if self.apiAppID.count > 10 {
            newRedditAPIPairState = .maybeValid
        } else if self.apiAppID.count > 0 {
            newRedditAPIPairState = .invalid
        }
        guard self.refreshToken != nil else { return newRedditAPIPairState }
        return .authorized
    }
    
    init(
        apiAppID: String = "",
        accessToken: String? = nil,
        refreshToken: String? = nil,
        expiration: Int? = nil,
        lastRefresh: Date? = nil,
        userName: String? = nil,
        profilePicture: String? = nil
    ) {
        self.id = UUID()
        self.apiAppID = apiAppID
        if let accessToken = accessToken, let expiration = expiration, let lastRefresh = lastRefresh {
            let newAccessToken = AccessToken(token: accessToken, expiration: expiration, lastRefresh: lastRefresh)
            self.accessToken = newAccessToken
        }
        self.refreshToken = refreshToken
        self.userName = userName
        self.profilePicture = profilePicture
    }
    
    mutating func clearIdentity() {
        accessToken = nil
        refreshToken = nil
        userName = nil
        profilePicture = nil
    }
    
    func getUpToDateToken(forceRenew: Bool = false) async -> (token: AccessToken?, updatedCredential: RedditCredential?) {
        guard let refreshToken = self.refreshToken, !apiAppID.isEmpty else {
            return (nil, nil)
        }
        if !forceRenew, let accessToken = self.accessToken {
            let lastRefresh = Double(accessToken.lastRefresh.timeIntervalSince1970)
            let expiration = Double(max(0, accessToken.expiration - 100))
            let now = Double(Date().timeIntervalSince1970)
            if (now - lastRefresh) < expiration {
                return (accessToken, nil)
            }
        }
        // Use RedditAPI for token refresh
        if let response = await RedditAPI.refreshAccessToken(
            appID: apiAppID,
            refreshToken: refreshToken
        ) {
            let newAccessToken = AccessToken(
                token: response.access_token,
                expiration: response.expires_in,
                lastRefresh: Date()
            )
            var updatedCredential = self
            updatedCredential.accessToken = newAccessToken
            return (newAccessToken, updatedCredential)
        } else {
            // Token refresh failed - clear credentials
            var clearedCredential = self
            clearedCredential.refreshToken = nil
            clearedCredential.accessToken = nil
            clearedCredential.userName = nil
            clearedCredential.profilePicture = nil
            return (nil, clearedCredential)
        }
    }
    
    struct AccessToken: Equatable, Hashable, Codable {
        let token: String
        let expiration: Int
        let lastRefresh: Date
    }
    
    enum CredentialValidationState: String {
        case authorized, valid, invalid, maybeValid, empty
        
        var meta: Meta {
            switch self {
            case .authorized: 
                .init(color: .green, label: "Authorized", description: "This credential is ready to use.")
            case .maybeValid, .valid:
                .init(color: .orange, label: "Unauthorized", description: "You need to authorize this credential with Reddit.")
            case .empty, .invalid:
                .init(color: .red, label: "Invalid", description: "The credential information is incorrect.")
            }
        }
        
        struct Meta {
            let color: Color
            let label: String
            let description: String
        }
    }
}

struct RefreshAccessTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

struct GetAccessTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let refresh_token: String
    let scope: String
    let expires_in: Int
}
