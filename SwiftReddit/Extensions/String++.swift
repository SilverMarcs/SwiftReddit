//
//  PostListingId.swift
//  SwiftReddit
//
//  Created on 18/06/2025.
//

import Foundation

typealias PostListingId = String

extension PostListingId {
    var withSubredditPrefix: String {
        return "r/\(self)"
    }
}
