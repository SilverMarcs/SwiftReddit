//
//  SubListingSortOption.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//

import Foundation

enum SubListingSortOption: String, CaseIterable, Identifiable {
    case best = "best"
    case hot = "hot"
    case new = "new"
    case controversial = "controversial"
    case top = "top"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .best: return "Best"
        case .hot: return "Hot"
        case .new: return "New"
        case .controversial: return "Controversial"
        case .top: return "Top"
        }
    }
    
    var icon: String {
        switch self {
        case .best: return "trophy"
        case .hot: return "flame"
        case .new: return "newspaper"
        case .controversial: return "figure.fencing"
        case .top: return "arrow.up.circle"
        }
    }
}
