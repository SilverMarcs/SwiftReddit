//
//  LightweightMediaType.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

enum LightweightMediaType: Hashable {
    case none
    case image(imageURL: String?)
    case gallery(count: Int, imageURL: String?)
    case video(thumbnailURL: String?)
    case youtube(thumbnailURL: String?)
    case link(thumbnailURL: String?)
    case gif(imageURL: String?)
    
    var hasMedia: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
    var imageURL: String? {
        switch self {
        case .none: return nil
        case .image(let url), .gallery(_, let url), .gif(let url):
            return url
        case .video(let url), .youtube(let url), .link(let url):
            return url
        }
    }
}
