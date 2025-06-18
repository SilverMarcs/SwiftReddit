//
//  ZoomableImageModal.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import SwiftUI

struct ZoomableImageModal: View {
    let imageURL: String
    
    var body: some View {
        if let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                ZoomableImage(image: image)
            } placeholder: {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }
}
