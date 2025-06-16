import Foundation

extension Subreddit {
    /// Fetch lightweight posts for home feed
    func fetchLightweightPosts(
        sort: String = "hot",
        limit: Int = 25,
        after: String? = nil
    ) async throws -> (posts: [LightweightPost], after: String?) {
        
        // Get credential from CredentialsManager
        guard let credential = CredentialsManager.shared.selectedCredential else {
            throw APIError.notAuthenticated
        }
        
        // Ensure we have a valid access token
        guard let accessToken = await credential.getUpToDateToken() else {
            throw APIError.notAuthenticated
        }
        
        // Construct URL
        var urlComponents = URLComponents(string: "https://oauth.reddit.com/")!
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        
        if let after = after {
            urlComponents.queryItems?.append(URLQueryItem(name: "after", value: after))
        }
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken.token)", forHTTPHeaderField: "Authorization")
        request.setValue("ios:com.example.winston:v1.0 (by /u/winston)", forHTTPHeaderField: "User-Agent")
        
        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        // Parse JSON
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataDict = json["data"] as? [String: Any],
              let children = dataDict["children"] as? [[String: Any]] else {
            throw APIError.invalidResponse
        }
        
        let posts = children.compactMap { child -> LightweightPost? in
            guard child["kind"] as? String == "t3" else { return nil }
            return LightweightPost(from: child)
        }
        
        let nextAfter = dataDict["after"] as? String
        
        return (posts: posts, after: nextAfter)
    }
}

enum APIError: Error, LocalizedError {
    case notAuthenticated
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated. Please add Reddit credentials."
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from Reddit"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
