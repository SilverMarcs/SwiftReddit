//
//  SingleImageView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct SingleImageView: View {
    let image: GalleryImage
    let namespace: Namespace.ID
    let onDismiss: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        ZStack {
            // Fixed black background
            Color.black
                .ignoresSafeArea()
            
            // Draggable image
            ImageView(url: URL(string: image.url), aspectRatio: image.aspectRatio)
                .matchedGeometryEffect(id: image.url, in: namespace)
                .tag(image.id)
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            // Only allow downward dragging
                            if value.translation.height > 0 {
                                dragOffset = value.translation
                            }
                        }
                        .onEnded { value in
                            isDragging = false
                            
                            // If dragged down more than 80 points, dismiss
                            if value.translation.height > 70 {
                                dismissImage()
                            } else {
                                // Spring back to original position
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    dragOffset = .zero
                                }
                            }
                        }
                )
                .zoomable()
        }
    }
    
    private func dismissImage() {
        withAnimation(.easeInOut(duration: 0.4)) {
            dragOffset = .zero
            onDismiss()
        }
    }
}
