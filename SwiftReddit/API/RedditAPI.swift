//
//  RedditAPI.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import Foundation

class RedditAPI {
    static let shared = RedditAPI()
    static let redditApiURLBase = "https://oauth.reddit.com"
    static let redditWWWApiURLBase = "https://www.reddit.com"
    static let appRedirectURI: String = "https://app.winston.cafe/auth-success"
    
    private init() {}
    
    // Pure HTTP client methods
    func fetchMe(with accessToken: String, userAgent: String) async -> UserData? {
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/v1/me") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let userData = try JSONDecoder().decode(UserData.self, from: data)
            return userData
        } catch {
            print("Fetch me error: \(error)")
            return nil
        }
    }
    
    func exchangeAuthCodeForTokens(appID: String, appSecret: String, authCode: String) async -> GetAccessTokenResponse? {
        var code = authCode
        if code.hasSuffix("#_") {
            code = String(code.dropLast(2))
        }
        
        guard let url = URL(string: "\(Self.redditWWWApiURLBase)/api/v1/access_token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Basic auth
        let credentials = "\(appID):\(appSecret)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Form data
        let formData = "grant_type=authorization_code&code=\(code)&redirect_uri=\(Self.appRedirectURI)"
        request.httpBody = formData.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(GetAccessTokenResponse.self, from: data)
            return response
        } catch {
            print("Access token exchange error: \(error)")
            return nil
        }
    }
    
    func refreshAccessToken(appID: String, appSecret: String, refreshToken: String) async -> RefreshAccessTokenResponse? {
        guard let url = URL(string: "\(Self.redditWWWApiURLBase)/api/v1/access_token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Basic auth
        let credentials = "\(appID):\(appSecret)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Form data
        let formData = "grant_type=refresh_token&refresh_token=\(refreshToken)"
        request.httpBody = formData.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(RefreshAccessTokenResponse.self, from: data)
            return response
        } catch {
            print("Token refresh error: \(error)")
            return nil
        }
    }
}
