//
//  SearchTab.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct SearchTab: View {
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                
            }
            .searchable(text: $searchText, prompt: "Search Subreddits")
        }
    }
}

#Preview {
    SearchTab()
}
