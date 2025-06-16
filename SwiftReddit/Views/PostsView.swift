//
//  PostsView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 16/06/2025.
//


import SwiftUI
import Combine

struct PostsView: View {
    @ObservedObject private var credentialsManager = CredentialsManager.shared
    
    var body: some View {
        SimpleFeed(subreddit: .home)
    }
}

