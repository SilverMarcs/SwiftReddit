//
//  BasicWebview.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI
import WebKit

struct BasicWebview: View {
    let linkMeta: LinkMetadata
    @State private var page = WebPage()
    
    var body: some View {
        if let url = URL(string: linkMeta.url) {
            WebView(page)
                .edgesIgnoringSafeArea(.bottom)
                .navigationTitle(page.title)
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    let request = URLRequest(url: url)
                    page.load(request)
                }
                #if !os(macOS)
                .toolbar(.hidden, for :.tabBar)
                #endif
        }
    }
}

//#Preview {
//    BasicWebview()
//}
