//
//  MultipleImagesView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct MultipleImagesView: View {
    let images: [GalleryImage]
    let namespace: Namespace.ID
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(images) { galleryImage in
                    ImageView(url: URL(string: galleryImage.url), aspectRatio: galleryImage.aspectRatio)
                        .matchedGeometryEffect(id: galleryImage.url, in: namespace)
                        .zoomable()
                        .frame(width: UIScreen.main.bounds.width)
                        .tag(galleryImage.id)
                }
            }
        }
        .ignoresSafeArea()
        .background(.black)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.height > 60 {
                        onDismiss()
                    }
                }
        )
        .scrollTargetBehavior(.paging)
    }
}
