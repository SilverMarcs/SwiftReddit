//
//  APIAuthentication.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 22/06/2025.
//

import Foundation

extension RedditAPI {
    static let appRedirectURI: String = "https://app.winston.cafe/auth-success"
    
    private func createBasicAuthHeader(appID: String, appSecret: String) -> String {
        let credentials = "\(appID):\(appSecret)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()
        return "Basic \(base64Credentials)"
    }
    
    func exchangeAuthCodeForTokens(appID: String, appSecret: String, authCode: String) async -> GetAccessTokenResponse? {
        let code = authCode.hasSuffix("#_") ? String(authCode.dropLast(2)) : authCode
        guard let url = URL(string: "\(Self.redditWWWApiURLBase)/api/v1/access_token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(createBasicAuthHeader(appID: appID, appSecret: appSecret), forHTTPHeaderField: "Authorization")
        request.httpBody = "grant_type=authorization_code&code=\(code)&redirect_uri=\(Self.appRedirectURI)".data(using: .utf8)
        
        return await performSimpleRequest(request, responseType: GetAccessTokenResponse.self)
    }
    
    func refreshAccessToken(appID: String, appSecret: String, refreshToken: String) async -> RefreshAccessTokenResponse? {
        guard let url = URL(string: "\(Self.redditWWWApiURLBase)/api/v1/access_token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(createBasicAuthHeader(appID: appID, appSecret: appSecret), forHTTPHeaderField: "Authorization")
        request.httpBody = "grant_type=refresh_token&refresh_token=\(refreshToken)".data(using: .utf8)
        
        return await performSimpleRequest(request, responseType: RefreshAccessTokenResponse.self)
    }
}
