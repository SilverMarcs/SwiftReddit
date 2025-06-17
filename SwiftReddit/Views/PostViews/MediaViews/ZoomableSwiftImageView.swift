//
//  ContentView.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//



import SwiftUI

/// A view that allows users to zoom and pan a SwiftUI image.
///
/// - Parameters:
///   - image: The `Image` to be displayed within the view.
///
/// The `ZoomableSwiftImageView` enables interactive image display allowing users to
/// pinch to zoom in and out as well as drag to reposition the image. It includes
/// double-tap functionality to quickly zoom in or reset the image to its original size.
///
/// ## Example Usage
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         ZoomableSwiftImageView(image: Image("my-image"))
///     }
/// }
/// ```
/// - Authors: IO DevBlue
/// - Since: v1.0.0
public struct ZoomableSwiftImageView: View {



	// MARK: Variables
	/// Define minimum and maximum scale factors
	/// The minimum scale factor for zooming.
	///
	/// This value determines the smallest scale at which the image can be displayed.
	private let minScale: CGFloat = 1.0
	/// The maximum scale factor for zooming.
	///
	/// This value determines the largest scale at which the image can be displayed.
	/// - Important: Setting a higher value can cause the image to be dragged completely out of the screen making snapping back impossible.
	private let maxScale: CGFloat = 2.5

	/// The current scale factor applied to the image.
	///
	/// This value determines how much the image is zoomed in or out.
	/// It starts at `1.0,` representing the image at its original size.
	@State private var scale: CGFloat = 1.0
	/// The last scale factor used during the magnification gesture.
	///
	/// This value is used to calculate the change in scale during the zooming interaction.
	/// It starts at `1.0` to match the initial scale factor.
	@State private var lastScale: CGFloat = 1.0
	/// The current offset position of the image.
	///
	/// This value represents the position of the image in relation to the view's coordinate space.
	/// It starts at `CGPoint.zero` meaning the image is initially centered in the view.
	@State private var offset: CGPoint = .zero
	/// The last translation size recorded during the drag gesture.
	///
	/// This value is used to calculate the difference in position while dragging the image.
	/// It starts at CGSize.zero to ensure accurate calculations for the initial drag.
	@State private var lastTranslation: CGSize = .zero

	/// The image to be displayed.
	///
	/// This property uses SwiftUI's `Image` type to represent the image that will be zoomed and panned.
	var image: Image
	/// The body of the view that defines the layout and behavior.
	///
	/// This computed property sets up the image display, including zooming and panning functionalities.
	///
	/// - Returns: A view that allows zooming and panning of the specified image.
	public var body: some View {
		GeometryReader { proxy in
			ZStack {
				image
					.resizable()
					.aspectRatio(contentMode: .fit)
					.scaleEffect(scale)
					.offset(x: offset.x, y: offset.y)
					.gesture(
						makeDragGesture(size: proxy.size)
							.simultaneously(with: makeMagnificationGesture(size: proxy.size))
					)
					.onTapGesture(count: 2) {
						withAnimation {
							if scale < maxScale {
								scale = min(max(scale * 2, minScale), maxScale) // Zoom in
							} else {
								scale = minScale // Reset to minimum scale
								offset = .zero // Reset the offset when zooming out
							}
						}
						adjustMaxOffset(size: proxy.size) // Adjust offsets after zooming
					}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.edgesIgnoringSafeArea(.all)
		}
	}



	// MARK: Initializers
	/// Creates a new instance of `ZoomableSwiftImageView`.
	///
	/// - Parameter image: The `Image` to be displayed within the view.
	///
	/// - Important: Ensure the image is properly initialized before using this initializer.
	public init(image: Image) {
		self.image = image
	}



	// MARK: Private functions
	/// Creates a magnification gesture for zooming the image.
	///
	/// This function generates a `MagnificationGesture` that updates the scale of the image
	/// based on user pinch gestures. It ensures that the scale remains within defined limits.
	///
	/// - Parameter size: The size of the view, used to adjust zoom behavior.
	/// - Returns: A gesture that modifies the image's scale based on user input.
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
					}
				}
				adjustMaxOffset(size: size)
			}
	}

	/// Creates a drag gesture for panning the image.
	///
	/// This function generates a `DragGesture` that allows the user to pan the image around the view.
	/// It updates the image's offset based on user drag movements, providing a natural dragging experience.
	///
	/// - Parameter size: The size of the view, used to adjust dragging behavior.
	/// - Returns: A gesture that modifies the image's offset based on user input.
	private func makeDragGesture(size: CGSize) -> some Gesture {
		DragGesture()
			.onChanged { value in
				let diff = CGPoint(
					x: value.translation.width - lastTranslation.width,
					y: value.translation.height - lastTranslation.height
				)
				offset = .init(x: offset.x + diff.x, y: offset.y + diff.y)
				lastTranslation = value.translation
			}
			.onEnded { value in
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

	/// Adjusts the maximum allowed offset for the image.
	///
	/// This function ensures that the image remains within defined boundaries based on the current
	/// scale and the size of the view. It snaps the image back to the allowed boundaries if it
	/// exceeds them, providing a smooth user experience.
	///
	/// - Parameter size: The size of the view, used to calculate maximum offsets.
	private func adjustMaxOffset(size: CGSize) {
		let maxOffsetX = (size.width * (scale - 1)) / 2
		let maxOffsetY = (size.height * (scale - 1)) / 2

		var newOffsetX = offset.x
		// BUG FIX: The Y-axis offset is doubled to create a more pronounced vertical movement effect
		// when the image is panned. Additionally, this adjustment helps to maintain
		// visual balance especially for images with a significantly wider aspect ratio compared to their height.
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
	ZoomableSwiftImageView(
		image:Image(systemName: "circle")
	)
	.frame(width: 300, height: 300)
}