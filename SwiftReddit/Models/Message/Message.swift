//
//  Message.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import Foundation

struct Message: Codable, Identifiable, Hashable {
    let id: String
    let subject: String?
    let author: String?
    let authorFullname: String?
    let subreddit: String?
    let subredditNamePrefixed: String?
    let body: String?
    let bodyHtml: String?
    let linkTitle: String?
    let dest: String?
    let context: String?
    let parentId: String?
    let name: String?
    let type: String?
    let created: Double?
    let createdUtc: Double?
    var isNew: Bool?
    let wasComment: Bool?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case subject
        case author
        case authorFullname = "author_fullname"
        case subreddit
        case subredditNamePrefixed = "subreddit_name_prefixed"
        case body
        case bodyHtml = "body_html"
        case linkTitle = "link_title"
        case dest
        case context
        case parentId = "parent_id"
        case name
        case type
        case created
        case createdUtc = "created_utc"
        case isNew = "new"
        case wasComment = "was_comment"
    }
    
    var createdDate: Date {
        if let created = created {
            return Date(timeIntervalSince1970: created)
        }
        return Date()
    }
}
