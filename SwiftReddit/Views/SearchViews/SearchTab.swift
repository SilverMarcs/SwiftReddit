//
//  SearchTab.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct SearchTab: View {
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            SearchView()
                .environment(\.appendToPath, { value in
                     path.append(value)
                 })
                .navigationDestinations()
        }
    }
}
