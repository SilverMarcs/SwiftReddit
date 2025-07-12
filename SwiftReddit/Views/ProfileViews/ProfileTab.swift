//
//  ProfileView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 25/06/2025.
//

import SwiftUI

struct ProfileTab: View {
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            UserSubredditsView()
                .navigationDestinations(append: { value in
                    path.append(value)
                })
        }
    }
}
