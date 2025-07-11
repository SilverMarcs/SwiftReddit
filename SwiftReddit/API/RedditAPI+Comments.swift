//
//  APICommentFetcher.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import Foundation

extension RedditAPI {
    /// Fetch post with comments
    func fetchPostWithComments(
        subreddit: String,
        postID: String,
        commentID: String? = nil,
        sort: CommentSortOption = .confidence,
        limit: Int = 100, // TODO: implement infinite scrolling
        depth: Int = 8
    ) async -> (Post?, [Comment], String?)? {
        guard let url = buildCommentsURL(
            subreddit: subreddit,
            postID: postID,
            commentID: commentID,
            sort: sort,
            limit: limit,
            depth: depth
        ) else {
            return nil
        }
        
        guard let response = await performAuthenticatedRequest(url: url, responseType: CommentResponse.self) else {
            return nil
        }
        
        // Extract post data
        let post: Post?
        if let postData = response.postListing.data.children.first?.data {
            // Filter out NSFW posts based on config setting
            if !Config.shared.allowNSFW && postData.over_18 == true {
                post = nil
            } else {
                post = Post(from: postData)
            }
        } else {
            post = nil
        }
        
        let comments = response.commentListing.data.children.compactMap { child -> Comment? in
            guard child.kind == "t1" else { return nil }
            return Comment(from: child.data)
        }
        
        return (post, comments, response.after)
    }

    // MARK: - URL Building
    
    func buildCommentsURL(
        subreddit: String,
        postID: String,
        commentID: String?,
        sort: CommentSortOption,
        limit: Int,
        depth: Int
    ) -> URL? {
        let cleanPostID = postID.hasPrefix("t3_") ? String(postID.dropFirst(3)) : postID
        var urlString = "\(Self.redditApiURLBase)/r/\(subreddit)/comments/\(cleanPostID)"
        
        if let commentID = commentID {
            let cleanCommentID = commentID.hasPrefix("t1_") ? String(commentID.dropFirst(3)) : commentID
            urlString += "/comment/\(cleanCommentID)"
        }
        
        urlString += ".json"
        
        var components = URLComponents(string: urlString)
        components?.queryItems = [
            URLQueryItem(name: "sort", value: sort.rawValue),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "depth", value: String(depth)),
            URLQueryItem(name: "raw_json", value: "1")
        ]
        
        return components?.url
    }
    
    // MARK: - Comment Actions
    
    /// Vote on a comment (upvote, downvote, or remove vote)
    /// - Parameters:
    ///   - action: The vote action to perform
    ///   - id: The fullname of the comment (e.g., t1_commentid)
    /// - Returns: true if successful, false otherwise
    @discardableResult
    func voteComment(_ action: VoteAction, id: String) async -> Bool? {
        guard let url = URL(string: "\(Self.redditApiURLBase)/api/vote") else {
            return nil
        }
        
        guard var request = await createAuthenticatedRequest(url: url, method: "POST") else {
            return nil
        }
        
        let parameters = "dir=\(action.rawValue)&id=\(id)&api_type=json&raw_json=1"
        request.httpBody = parameters.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            AppLogger.critical("Comment vote error: \(error.localizedDescription)")
            return nil
        }
    }
}
