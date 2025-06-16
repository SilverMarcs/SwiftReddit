//
//  RedditAPI.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import Foundation

@Observable
class RedditAPI {
    static let shared = RedditAPI()
    static let redditApiURLBase = "https://oauth.reddit.com"
    static let redditWWWApiURLBase = "https://www.reddit.com"
    static let appRedirectURI: String = "https://app.winston.cafe/auth-success"
    
    var lastAuthState: String?
    var me: UserData?
    
    private init() {}
    
    func getAuthorizationCodeURL(_ appID: String) -> URL {
        let response_type: String = "code"
        let state: String = UUID().uuidString
        let redirect_uri: String = Self.appRedirectURI
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
    
    func injectFirstAccessTokenInto(_ credential: RedditCredential, authCode: String) async -> RedditCredential? {
        guard !credential.apiAppID.isEmpty && !credential.apiAppSecret.isEmpty else { return nil }
        
        var updatedCredential = credential
        var code = authCode
        if code.hasSuffix("#_") {
            code = String(code.dropLast(2))
        }
        
        guard let url = URL(string: "\(Self.redditWWWApiURLBase)/api/v1/access_token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Basic auth
        let credentials = "\(updatedCredential.apiAppID):\(updatedCredential.apiAppSecret)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Form data
        let formData = "grant_type=authorization_code&code=\(code)&redirect_uri=\(Self.appRedirectURI)"
        request.httpBody = formData.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(GetAccessTokenResponse.self, from: data)
            
            let newAccessToken = RedditCredential.AccessToken(
                token: response.access_token,
                expiration: response.expires_in,
                lastRefresh: Date()
            )
            
            updatedCredential.refreshToken = response.refresh_token
            updatedCredential.accessToken = newAccessToken
            
            // Fetch user info
            if let meData = await fetchMe(altCredential: updatedCredential) {
                updatedCredential.userName = meData.name
                if let iconImg = meData.icon_img, !iconImg.isEmpty {
                    updatedCredential.profilePicture = iconImg
                }
            }
            
            return updatedCredential
        } catch {
            print("Access token exchange error: \(error)")
            return nil
        }
    }
    
    func fetchMe(altCredential: RedditCredential? = nil) async -> UserData? {
        let credential = altCredential ?? CredentialsManager.shared.selectedCredential
        guard let credential = credential,
              let accessToken = await credential.getUpToDateToken() else {
            return nil
        }
        
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/v1/me") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken.token)", forHTTPHeaderField: "Authorization")
        request.setValue("ios:lo.cafe.winston:v0.1.0 (by /u/\(credential.userName ?? "UnknownUser"))", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let userData = try JSONDecoder().decode(UserData.self, from: data)
            
            self.me = userData
            
            return userData
        } catch {
            print("Fetch me error: \(error)")
            return nil
        }
    }
}
