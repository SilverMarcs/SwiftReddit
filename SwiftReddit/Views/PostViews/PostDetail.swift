//
//  PostDetail.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import SwiftUI

struct PostDetail: View {
    var post: Post
    
    var body: some View {
        List {
            Section {
                PostView(post: post)
                    .listRowSeparator(.hidden)
            }
            
            Section {
                ForEach(0..<15, id: \.self) { index in
                    Text("Comment \(index + 1)")
                        .padding()
                }
            }   
        }
        .listStyle(.plain)
    }
}

//#Preview {
//    PostDetail()
//}
