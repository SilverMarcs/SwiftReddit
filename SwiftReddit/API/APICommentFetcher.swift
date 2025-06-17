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
        limit: Int = 100,
        depth: Int = 15
    ) async -> ([Comment], String?)? {
        guard let accessToken = await CredentialsManager.shared.getValidAccessToken() else {
            print("No valid credential or access token")
            return nil
        }
        
        // Clean postID (remove t3_ prefix if present)
        let cleanPostID = postID.hasPrefix("t3_") ? String(postID.dropFirst(3)) : postID
        
        // Build URL
        var urlString = "\(Self.redditApiURLBase)/r/\(subreddit)/comments/\(cleanPostID)"
        
        // Add specific comment path if provided
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
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let userName = CredentialsManager.shared.credential?.userName ?? "UnknownUser"
        request.setValue("ios:lo.cafe.winston:v0.1.0 (by /u/\(userName))", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("Reddit API Error: Status \(httpResponse.statusCode)")
                    return nil
                }
            }
            
            // Reddit returns an array with 2 elements: [post_listing, comments_listing]
            // We need to handle this as a mixed response since posts and comments have different structures
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let responseArray = jsonObject as? [[String: Any]],
                  responseArray.count >= 2,
                  let commentsListingData = responseArray[1] as? [String: Any],
                  let commentsData = commentsListingData["data"] as? [String: Any],
                  let commentsChildren = commentsData["children"] as? [[String: Any]] else {
                print("Unexpected response format")
                return nil
            }
            
            // Parse comments manually to handle the nested structure properly
            var comments: [Comment] = []
            
            for childData in commentsChildren {
                if let kind = childData["kind"] as? String,
                   kind == "t1",
                   let commentDataDict = childData["data"] as? [String: Any] {
                    
                    if let commentData = try? parseCommentData(from: commentDataDict) {
                        comments.append(Comment(from: commentData))
                    }
                }
            }
            
            let after = commentsData["after"] as? String
            return (comments, after)
            
        } catch {
            print("Fetch comments error: \(error)")
            return nil
        }
    }
    
    /// Helper method to parse comment data from dictionary
    private func parseCommentData(from dict: [String: Any]) throws -> CommentData {
        // Extract required fields
        guard let id = dict["id"] as? String,
              let author = dict["author"] as? String,
              let body = dict["body"] as? String,
              let bodyHTML = dict["body_html"] as? String,
              let createdUTC = dict["created_utc"] as? Double,
              let name = dict["name"] as? String else {
            throw NSError(domain: "CommentParsingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing required comment fields"])
        }
        
        // Parse replies recursively
        var replies: CommentReplies? = nil
        if let repliesData = dict["replies"] as? [String: Any] {
            // This is a nested listing, parse recursively
            if let data = repliesData["data"] as? [String: Any],
               let children = data["children"] as? [[String: Any]] {
                
                var childComments: [CommentData] = []
                for child in children {
                    if let childKind = child["kind"] as? String,
                       childKind == "t1",
                       let childDataDict = child["data"] as? [String: Any],
                       let childComment = try? parseCommentData(from: childDataDict) {
                        childComments.append(childComment)
                    }
                }
                
                let listingData = ListingData<CommentData>(
                    after: data["after"] as? String,
                    before: data["before"] as? String,
                    children: childComments.map { ListingChild(kind: "t1", data: $0) }
                )
                
                let listing = Listing<CommentData>(kind: repliesData["kind"] as? String ?? "Listing", data: listingData)
                replies = .listing(listing)
            }
        } else if dict["replies"] as? String != nil {
            replies = .empty("")
        }
        
        return CommentData(
            id: id,
            author: author,
            body: body,
            body_html: bodyHTML,
            created_utc: createdUTC,
            score: dict["score"] as? Int,
            ups: dict["ups"] as? Int,
            downs: dict["downs"] as? Int,
            likes: dict["likes"] as? Bool,
            saved: dict["saved"] as? Bool ?? false,
            archived: dict["archived"] as? Bool ?? false,
            depth: dict["depth"] as? Int,
            permalink: dict["permalink"] as? String,
            parent_id: dict["parent_id"] as? String,
            link_id: dict["link_id"] as? String,
            subreddit: dict["subreddit"] as? String,
            subreddit_id: dict["subreddit_id"] as? String,
            name: name,
            author_fullname: dict["author_fullname"] as? String,
            author_flair_text: dict["author_flair_text"] as? String,
            author_flair_background_color: dict["author_flair_background_color"] as? String,
            is_submitter: dict["is_submitter"] as? Bool,
            send_replies: dict["send_replies"] as? Bool ?? true,
            collapsed: dict["collapsed"] as? Bool ?? false,
            count: dict["count"] as? Int,
            children: dict["children"] as? [String],
            mod_reports: dict["mod_reports"] as? [String],
            num_reports: dict["num_reports"] as? Int,
            distinguished: dict["distinguished"] as? String,
            stickied: dict["stickied"] as? Bool,
            locked: dict["locked"] as? Bool,
            can_gild: dict["can_gild"] as? Bool,
            gilded: dict["gilded"] as? Int,
            total_awards_received: dict["total_awards_received"] as? Int,
            top_awarded_type: dict["top_awarded_type"] as? String,
            replies: replies
        )
    }
}
