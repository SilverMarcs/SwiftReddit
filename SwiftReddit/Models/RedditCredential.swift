//
//  RedditCredential.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import Foundation

struct RedditCredential: Identifiable, Equatable, Hashable, Codable {
    enum CodingKeys: String, CodingKey { 
        case id, apiAppID, apiAppSecret, accessToken, refreshToken, userName, profilePicture 
    }
    
    var id: UUID
    var apiAppID: String { 
        willSet { 
            if apiAppID != newValue { 
                clearIdentity() 
            } 
        } 
    }
    var apiAppSecret: String { 
        willSet { 
            if apiAppSecret != newValue { 
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
        
        if self.apiAppID.count == 22 && self.apiAppSecret.count == 30 {
            newRedditAPIPairState = .valid
        } else if self.apiAppID.count > 10 && self.apiAppSecret.count > 20 {
            newRedditAPIPairState = .maybeValid
        } else if self.apiAppID.count > 0 || self.apiAppSecret.count > 0 {
            newRedditAPIPairState = .invalid
        }
        
        guard self.refreshToken != nil else { return newRedditAPIPairState }
        return .authorized
    }
    
    init(
        apiAppID: String = "",
        apiAppSecret: String = "",
        accessToken: String? = nil,
        refreshToken: String? = nil,
        expiration: Int? = nil,
        lastRefresh: Date? = nil,
        userName: String? = nil,
        profilePicture: String? = nil
    ) {
        self.id = UUID()
        self.apiAppID = apiAppID
        self.apiAppSecret = apiAppSecret
        
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
    
    func save() {
        CredentialsManager.shared.saveCredential(self)
    }
    
    func delete() {
        CredentialsManager.shared.deleteCredential(self)
    }
    
    func getUpToDateToken(forceRenew: Bool = false) async -> AccessToken? {
        guard let refreshToken = self.refreshToken, !apiAppID.isEmpty && !apiAppSecret.isEmpty else { return nil }
        
        if !forceRenew, let accessToken = self.accessToken {
            let lastRefresh = Double(accessToken.lastRefresh.timeIntervalSince1970)
            let expiration = Double(max(0, accessToken.expiration - 100))
            let now = Double(Date().timeIntervalSince1970)
            
            if (now - lastRefresh) < expiration {
                return accessToken
            }
        }
        
        return await fetchNewToken()
        
        func fetchNewToken() async -> AccessToken? {
            let payload = RefreshAccessTokenPayload(refresh_token: refreshToken)
            
            guard let url = URL(string: "\(RedditAPI.redditWWWApiURLBase)/api/v1/access_token") else { return nil }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // Basic auth
            let credentials = "\(apiAppID):\(apiAppSecret)"
            let base64Credentials = Data(credentials.utf8).base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            
            // Form data
            let formData = "grant_type=refresh_token&refresh_token=\(refreshToken)"
            request.httpBody = formData.data(using: .utf8)
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode(RefreshAccessTokenResponse.self, from: data)
                
                let newAccessToken = AccessToken(
                    token: response.access_token,
                    expiration: response.expires_in,
                    lastRefresh: Date()
                )
                
                var newSelf = self
                newSelf.accessToken = newAccessToken
                CredentialsManager.shared.saveCredential(newSelf)
                
                return newAccessToken
            } catch {
                print("Token refresh error: \(error)")
                
                // Clear invalid credentials
                var selfCopy = self
                selfCopy.refreshToken = nil
                selfCopy.accessToken = nil
                selfCopy.userName = nil
                selfCopy.profilePicture = nil
                selfCopy.save()
                
                return nil
            }
        }
    }
    
    struct AccessToken: Equatable, Hashable, Codable {
        let token: String
        let expiration: Int
        let lastRefresh: Date
    }
    
    enum CredentialValidationState: String {
        case authorized, valid, invalid, maybeValid, empty
        
        func getMeta() -> Meta {
            return switch self {
            case .authorized: 
                .init(color: "green", label: "Authorized", description: "This credential is ready to use.")
            case .maybeValid, .valid: 
                .init(color: "orange", label: "Unauthorized", description: "You need to authorize this credential with Reddit.")
            case .empty, .invalid: 
                .init(color: "red", label: "Invalid", description: "The credential information is incorrect.")
            }
        }
        
        struct Meta: Equatable {
            let color: String
            let label: String
            let description: String
        }
    }
}

struct RefreshAccessTokenPayload: Encodable {
    let grant_type = "refresh_token"
    let refresh_token: String
}

struct RefreshAccessTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

struct GetAccessTokenPayload: Encodable {
    let grant_type = "authorization_code"
    let code: String
    let redirect_uri = RedditAPI.appRedirectURI
}

struct GetAccessTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let refresh_token: String
    let scope: String
    let expires_in: Int
}
