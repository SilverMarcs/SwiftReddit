//
//  APIAuthentication.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 22/06/2025.
//

import Foundation

extension RedditAPI {
    private func createBasicAuthHeader(appID: String, appSecret: String) -> String {
        let credentials = "\(appID):\(appSecret)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()
        return "Basic \(base64Credentials)"
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
        request.setValue(createBasicAuthHeader(appID: appID, appSecret: appSecret), forHTTPHeaderField: "Authorization")
        
        let formData = "grant_type=authorization_code&code=\(code)&redirect_uri=\(Self.appRedirectURI)"
        request.httpBody = formData.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(GetAccessTokenResponse.self, from: data)
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
        request.setValue(createBasicAuthHeader(appID: appID, appSecret: appSecret), forHTTPHeaderField: "Authorization")
        
        let formData = "grant_type=refresh_token&refresh_token=\(refreshToken)"
        request.httpBody = formData.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(RefreshAccessTokenResponse.self, from: data)
        } catch {
            print("Token refresh error: \(error)")
            return nil
        }
    }
}
