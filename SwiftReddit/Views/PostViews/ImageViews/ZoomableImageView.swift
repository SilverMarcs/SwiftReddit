//
//  ContentView.swift
//  SwiftReddit
//
//  Created by IODevBlue on 18/06/2025.
//

import SwiftUI

public struct ZoomableImage: View {
	private let minScale: CGFloat = 1.0
	private let maxScale: CGFloat = 2.5

	@State private var scale: CGFloat = 1.0
	@State private var lastScale: CGFloat = 1.0
	@State private var offset: CGPoint = .zero
	@State private var lastTranslation: CGSize = .zero

	var image: Image

	public var body: some View {
		GeometryReader { proxy in
			ZStack {
				image
					.resizable()
					.aspectRatio(contentMode: .fit)
					.scaleEffect(scale)
					.offset(x: offset.x, y: offset.y)
					.gesture(
						makeMagnificationGesture(size: proxy.size)
					)
					.gesture(
						makeDragGesture(size: proxy.size),
						including: scale > minScale ? .all : .none
					)
					.onTapGesture(count: 2, coordinateSpace: .local) { location in
						handleDoubleTap(at: location, size: proxy.size)
					}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.edgesIgnoringSafeArea(.all)
		}
	}

	public init(image: Image) {
		self.image = image
	}
    
	private func makeMagnificationGesture(size: CGSize) -> some Gesture {
		MagnificationGesture()
			.onChanged { value in
				let delta = value / lastScale
				lastScale = value

				// Allow zooming beyond maxScale during pinch but minimize jitter
				if abs(1 - delta) > 0.01 {
					scale *= delta // Let the user zoom freely
				}
			}
			.onEnded { _ in
				lastScale = 1
				// Snap back to max scale if exceeding maxScale
				if scale > maxScale {
					withAnimation {
						scale = maxScale
					}
				}
				// Snap back to min scale if below minScale
				else if scale < minScale {
					withAnimation {
						scale = minScale
						offset = .zero // Reset offset when returning to min scale
					}
					lastTranslation = .zero
				}
				adjustMaxOffset(size: size)
			}
	}

	private func makeDragGesture(size: CGSize) -> some Gesture {
		DragGesture()
			.onChanged { value in
				// Only handle drag if image is zoomed in
				guard scale > minScale else { return }
				
				let diff = CGPoint(
					x: value.translation.width - lastTranslation.width,
					y: value.translation.height - lastTranslation.height
				)
				offset = .init(x: offset.x + diff.x, y: offset.y + diff.y)
				lastTranslation = value.translation
			}
			.onEnded { value in
				// Only handle drag end if image is zoomed in
				guard scale > minScale else { 
					lastTranslation = .zero
					return 
				}
				
				// Calculate the velocity of the drag
				let velocity = value.predictedEndTranslation
				let damping: CGFloat = 0.5 // Adjust damping for smoother effect

				// Apply inertia to the offset with animation
				withAnimation(.easeOut(duration: 0.5)) {
					offset.x += velocity.width * damping
					offset.y += velocity.height * damping
				}

				// Adjust the max offset after applying the velocity
				adjustMaxOffset(size: size)
			}
	}

	private func handleDoubleTap(at location: CGPoint, size: CGSize) {
		let centerX = size.width / 2
		let centerY = size.height / 2
		
		withAnimation(.easeInOut(duration: 0.3)) {
			if scale == minScale {
				// Zoom in to the tapped location
				scale = maxScale
				
				// Calculate offset to center the tapped area
				let zoomOffset = CGPoint(
					x: (centerX - location.x) * (maxScale - 1),
					y: (centerY - location.y) * (maxScale - 1)
				)
				offset = zoomOffset
			} else {
				// Zoom out and reset
				scale = minScale
				offset = .zero
				lastTranslation = .zero
			}
		}
		adjustMaxOffset(size: size)
	}

	private func makeDoubleTapGesture(size: CGSize) -> some Gesture {
		TapGesture(count: 2)
			.onEnded { value in
				// Need to get tap location from a DragGesture instead
			}
	}
	
	private func makeDoubleTapLocationGesture(size: CGSize) -> some Gesture {
		DragGesture(minimumDistance: 0, coordinateSpace: .local)
			.onEnded { value in
				// Calculate the tap location relative to the image center
				let tapLocation = value.location
				let centerX = size.width / 2
				let centerY = size.height / 2
				
				withAnimation(.easeInOut(duration: 0.3)) {
					if scale == minScale {
						// Zoom in to the tapped location
						scale = maxScale
						
						// Calculate offset to center the tapped area
						let zoomOffset = CGPoint(
							x: (centerX - tapLocation.x) * (maxScale - 1),
							y: (centerY - tapLocation.y) * (maxScale - 1)
						)
						offset = zoomOffset
					} else {
						// Zoom out and reset
						scale = minScale
						offset = .zero
						lastTranslation = .zero
					}
				}
				adjustMaxOffset(size: size)
			}
	}

	private func adjustMaxOffset(size: CGSize) {
		let maxOffsetX = (size.width * (scale - 1)) / 2
		let maxOffsetY = (size.height * (scale - 1)) / 2

		var newOffsetX = offset.x

		var newOffsetY = offset.y

		// Horizontal boundary check
		if abs(newOffsetX) > maxOffsetX {
			newOffsetX = maxOffsetX * (abs(newOffsetX) / newOffsetX)
		}

		// Vertical boundary check
		if abs(newOffsetY) > maxOffsetY {
			newOffsetY = maxOffsetY * (abs(newOffsetY) / newOffsetY)
		}

		// Check for snapping back to safe zones
		let snapBackOffsetY = (newOffsetY > 0) ? 0 : -maxOffsetY
		let snapBackOffsetX = (newOffsetX > 0) ? 0 : -maxOffsetX

		let shouldSnapBackY = newOffsetY < -maxOffsetY || newOffsetY > maxOffsetY
		let shouldSnapBackX = newOffsetX < -maxOffsetX || newOffsetX > maxOffsetX

		if shouldSnapBackY {
			newOffsetY = snapBackOffsetY
		}
		if shouldSnapBackX {
			newOffsetX = snapBackOffsetX
		}

		let newOffset = CGPoint(x: newOffsetX, y: newOffsetY)
		if newOffset != offset {
			withAnimation {
				offset = newOffset
			}
		}
		self.lastTranslation = .zero
	}

}

#Preview {
	ZoomableImage(
		image:Image(systemName: "circle")
	)
	.frame(width: 300, height: 300)
}
