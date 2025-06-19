//
//  AppConfig.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import Foundation
import SwiftUI

@Observable
class AppConfig {
    var path: NavigationPath = NavigationPath()
    
    // Track navigation history for intelligent navigation
    private var navigationHistory: [Any] = []
    
    func navigateToSubreddit(_ subreddit: Subreddit) {
        // Check if we're already in this subreddit's context
        if let lastSubreddit = getCurrentSubreddit() {
            if lastSubreddit.displayName == subreddit.displayName {
                // We're trying to navigate to the same subreddit, go back instead
                popToSubreddit(subreddit)
                return
            }
        }
        
        // Normal navigation - append to path
        path.append(subreddit)
        navigationHistory.append(subreddit)
    }
    
    func navigateToPost(_ post: Post) {
        path.append(post)
        navigationHistory.append(post)
    }
    
    func navigateToLink(_ linkMetadata: LinkMetadata) {
        path.append(linkMetadata)
        navigationHistory.append(linkMetadata)
    }
    
    private func getCurrentSubreddit() -> Subreddit? {
        // Look through navigation history backwards to find the most recent subreddit
        for item in navigationHistory.reversed() {
            if let subreddit = item as? Subreddit {
                return subreddit
            }
        }
        return nil
    }
    
    private func popToSubreddit(_ targetSubreddit: Subreddit) {
        // Find the index of the target subreddit in our history
        var popCount = 0
        
        for item in navigationHistory.reversed() {
            if let subreddit = item as? Subreddit, 
               subreddit.displayName == targetSubreddit.displayName {
                break
            }
            popCount += 1
        }
        
        // Pop the navigation stack
        if popCount > 0 {
            for _ in 0..<popCount {
                if !path.isEmpty {
                    path.removeLast()
                }
                if !navigationHistory.isEmpty {
                    navigationHistory.removeLast()
                }
            }
        }
    }
    
    func popLast() {
        if !path.isEmpty {
            path.removeLast()
        }
        if !navigationHistory.isEmpty {
            navigationHistory.removeLast()
        }
    }
    
    func clearNavigation() {
        path = NavigationPath()
        navigationHistory.removeAll()
    }
}
