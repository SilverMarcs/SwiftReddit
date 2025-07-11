//
//  FlatComment.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

/// Flattened comment for list display
struct FlatComment: Identifiable, Hashable, Votable {
    let id: String
    let author: String
    let body: String
    let created: Double
    let score: Int
    let ups: Int
    let depth: Int
    let parentID: String?
    let isSubmitter: Bool
    let authorFlairText: String?
    let authorFlairBackgroundColor: String?
    let distinguished: String?
    let stickied: Bool
    let likes: Bool?
    
    // Flattened display properties
    let isVisible: Bool
    let hasChildren: Bool
    let isCollapsed: Bool
    let childCount: Int
    
    var fullname: String {
        return "t1_\(id)"
    }
    
    var flairBackgroundColor: Color {
        guard let bgColor = authorFlairBackgroundColor, !bgColor.isEmpty else {
            return Color.clear
        }
        return Color(hex: bgColor)
    }
    
    static func colorForDepth(_ depth: Int) -> Color {
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .red, .pink, .teal, .indigo
        ]
        let index = (depth - 1) % colors.count
        return colors[index]
    }
}
