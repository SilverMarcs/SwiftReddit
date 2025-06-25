//
//  RedditAPI.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

extension RedditAPI {
    // MARK: - Post Actions
    
    /// Save or unsave a post
    /// - Parameters:
    ///   - save: true to save, false to unsave
    ///   - id: The fullname of the post (e.g., t3_postid)
    /// - Returns: true if successful, false otherwise
    func save(_ save: Bool, id: String) async -> Bool? {
        let endpoint = save ? "save" : "unsave"
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/\(endpoint)") else {
            return nil
        }
        
        guard var request = await createAuthenticatedRequest(url: url, method: "POST") else {
            return nil
        }
        
        let parameters = "id=\(id)"
        request.httpBody = parameters.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            AppLogger.critical("Save/unsave error: \(error.localizedDescription)")
            return nil
        }
    }
}
