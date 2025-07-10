//
//  URLHandlingModifier.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 20/06/2025.
//

import SwiftUI

struct URLHandlingModifier: ViewModifier {
    @Environment(Nav.self) private var nav
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                URLHandler.handleURL(url, nav: nav)
            })
    }
}

extension View {
    /// Applies Reddit-aware URL handling to this view
    func handleURLs() -> some View {
        modifier(URLHandlingModifier())
    }
}
