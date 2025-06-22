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
        depth: Int = 15
    ) async -> ([Comment], String?)? {
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
        
        let comments = response.commentListing.data.children.compactMap { child -> Comment? in
            guard child.kind == "t1" else { return nil }
            return Comment(from: child.data)
        }
        
        return (comments, response.after)
    }

    // MARK: - URL Building
    
    private func buildCommentsURL(
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
}
