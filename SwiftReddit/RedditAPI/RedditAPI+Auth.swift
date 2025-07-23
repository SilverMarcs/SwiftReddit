//
//  APIAuthentication.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 22/06/2025.
//

import Foundation

extension RedditAPI {
    // For installed app flow, use custom scheme redirect URI
    static let appRedirectURI: String = "swiftddit://auth-success"

    // Reddit requires HTTP Basic Auth for installed apps: client_id as username, empty password
    private static func createInstalledAppAuthHeader(appID: String) -> String {
        let credentials = "\(appID):"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()
        return "Basic \(base64Credentials)"
    }
    
    // No basic auth header needed for installed app flow
    
    static func exchangeAuthCodeForTokens(appID: String, authCode: String) async -> GetAccessTokenResponse? {
        let code = authCode.hasSuffix("#_") ? String(authCode.dropLast(2)) : authCode
        guard let url = URL(string: "\(Self.redditWWWApiURLBase)/api/v1/access_token") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(createInstalledAppAuthHeader(appID: appID), forHTTPHeaderField: "Authorization")
        // Do NOT include client_id in body for installed app, only in header
        request.httpBody = "grant_type=authorization_code&code=\(code)&redirect_uri=\(Self.appRedirectURI)".data(using: .utf8)
        return await performSimpleRequest(request, responseType: GetAccessTokenResponse.self)
    }
    
    static func refreshAccessToken(appID: String, refreshToken: String) async -> RefreshAccessTokenResponse? {
        guard let url = URL(string: "\(Self.redditWWWApiURLBase)/api/v1/access_token") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(createInstalledAppAuthHeader(appID: appID), forHTTPHeaderField: "Authorization")
        // Do NOT include client_id in body for installed app, only in header
        request.httpBody = "grant_type=refresh_token&refresh_token=\(refreshToken)&redirect_uri=\(Self.appRedirectURI)".data(using: .utf8)
        return await performSimpleRequest(request, responseType: RefreshAccessTokenResponse.self)
    }
}
