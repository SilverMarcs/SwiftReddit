//
//  RedditAPI.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import Foundation

struct RedditAPI {
    static let shared = RedditAPI()
    static let redditApiURLBase = "https://oauth.reddit.com"
    static let redditWWWApiURLBase = "https://www.reddit.com"
    
    private init() {}
    
    func createUserAgent() -> String {
        let userName = CredentialsManager.shared.credential?.userName ?? "UnknownUser"
        return "ios:com.SilverMarcs.SwiftReddit:v0.1.0 (by /u/\(userName))"
    }
    
    internal func createAuthenticatedRequest(url: URL, method: String = "GET") async -> URLRequest? {
        guard let accessToken = await CredentialsManager.shared.getValidAccessToken() else {
            AppLogger.error("No valid credential or access token")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(createUserAgent(), forHTTPHeaderField: "User-Agent")
        return request
    }
    
    internal func performAuthenticatedRequest<T: Codable>(url: URL, responseType: T.Type) async -> T? {
        guard let request = await createAuthenticatedRequest(url: url) else { return nil }
        return await performRequest(request, responseType: responseType, endpoint: url.absoluteString)
    }
    
    internal func performPostRequest(url: URL, parameters: String) async -> Bool {
        guard var request = await createAuthenticatedRequest(url: url, method: "POST") else { return false }
        request.httpBody = parameters.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return await performSimpleRequest(request)
    }
    
    internal func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type, endpoint: String) async -> T? {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
//            AppLogger.logAPIResponse(data, responseType: responseType, endpoint: endpoint)
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            AppLogger.critical("Network error: \(error.localizedDescription)")
            return nil
        }
    }
    
    internal func performSimpleRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async -> T? {
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            return nil
        }
    }
    
    private func performSimpleRequest(_ request: URLRequest) async -> Bool {
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
