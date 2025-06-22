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
    
    private init() {}
    
    private func createUserAgent() -> String {
        let userName = CredentialsManager.shared.credential?.userName ?? "UnknownUser"
        return "ios:com.SilverMarcs.SwiftReddit:v0.1.0 (by /u/\(userName))"
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
            AppLogger.error("No valid credential or access token")
            return nil
        }
        
        let request = createAuthenticatedRequest(url: url, accessToken: accessToken)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            AppLogger.logAPIResponse(data, endpoint: url.absoluteString)
            
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            AppLogger.error(error.localizedDescription)
            return nil
        }
    }
}
