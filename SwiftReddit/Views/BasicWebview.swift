//
//  BasicWebview.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI
import WebKit
import Observation

struct BasicWebview: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let linkMeta: LinkMetadata
    @State private var page = WebPage()
    @State private var isDarkModeEnabled = false
    
    var body: some View {
        if let url = URL(string: linkMeta.url) {
            WebView(page)
                .edgesIgnoringSafeArea(.bottom)
                .navigationTitle(page.title)
                .toolbarTitleDisplayMode(.inline)
                .onAppear {
                    let request = URLRequest(url: url)
                    page.load(request)
                    Task {
                        // wait 1 second for the page to load
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        if colorScheme == .dark {
                            isDarkModeEnabled = true
                            toggleDarkMode()
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            isDarkModeEnabled.toggle()
                            toggleDarkMode()
                        } label: {
                            Label("Dark Mode", systemImage: isDarkModeEnabled ? "moon.fill" : "moon")
                        }
                        
                        Button {
                            if let url = URL(string: linkMeta.url) {
                                #if os(iOS)
                                UIApplication.shared.open(url)
                                #elseif os(macOS)
                                NSWorkspace.shared.open(url)
                                #endif
                            }
                        } label: {
                            Label("Open in Safari", systemImage: "safari")
                        }
                    }
                }
                #if !os(macOS)
                .toolbar(.hidden, for :.tabBar)
                #endif
        }
    }
    
    private func toggleDarkMode() {
        let darkModeCSS = """
        if (document.getElementById('swift-reddit-dark-mode')) {
            document.getElementById('swift-reddit-dark-mode').remove();
        } else {
            const style = document.createElement('style');
            style.id = 'swift-reddit-dark-mode';
            style.innerHTML = `
                * {
                    background-color: #131313 !important;
                    color: #ffffff !important;
                    border-color: #333333 !important;
                }
                
                body {
                    background-color: #1a1a1a !important;
                    color: #ffffff !important;
                }
                
                a, a:visited {
                    color: #60a5fa !important;
                }
                
                a:hover {
                    color: #93c5fd !important;
                }
                
                input, textarea, select {
                    background-color: #2d2d2d !important;
                    color: #ffffff !important;
                    border: 1px solid #444444 !important;
                }
                
                button {
                    background-color: #2d2d2d !important;
                    color: #ffffff !important;
                    border: 1px solid #444444 !important;
                }
                
                img {
                    opacity: 0.8 !important;
                }
                
                [style*="background-color"] {
                    background-color: #1a1a1a !important;
                }
                
                [style*="color"] {
                    color: #ffffff !important;
                }
            `;
            document.head.appendChild(style);
        }
        """
        
        Task {
            do {
                try await page.callJavaScript(darkModeCSS)
            } catch {
                print("Error toggling dark mode: \(error)")
            }
        }
    }
}

//#Preview {
//    BasicWebview()
//}
