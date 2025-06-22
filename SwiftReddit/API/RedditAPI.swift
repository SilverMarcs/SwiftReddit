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
    
    // MARK: - Common Helper Methods
    
    private func createUserAgent() -> String {
        let userName = CredentialsManager.shared.credential?.userName ?? "UnknownUser"
        return "ios:com.SilverMarcs.SwiftReddit:v0.1.0 (by /u/\(userName))"
    }
    
    private func createBasicAuthHeader(appID: String, appSecret: String) -> String {
        let credentials = "\(appID):\(appSecret)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()
        return "Basic \(base64Credentials)"
    }
    
    internal func createAuthenticatedRequest(url: URL, method: String = "GET", accessToken: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(createUserAgent(), forHTTPHeaderField: "User-Agent")
        return request
    }
    
    internal func performAuthenticatedRequest<T: Codable>(url: URL, responseType: T.Type) async -> T? {
        guard let accessToken = await CredentialsManager.shared.getValidAccessToken() else {
            print("No valid credential or access token")
            return nil
        }
        
        let request = createAuthenticatedRequest(url: url, accessToken: accessToken)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Reddit API Error: Status \(httpResponse.statusCode)")
                return nil
            }
            
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            print("API request error: \(error)")
            return nil
        }
    }
    
    // MARK: - Authentication Methods
    
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
