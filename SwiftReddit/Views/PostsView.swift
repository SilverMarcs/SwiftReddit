//
//  PostsView.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import SwiftUI

struct PostsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Posts")
                    .font(.largeTitle)
                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Posts")
        }
    }
}

#Preview {
    PostsView()
}
