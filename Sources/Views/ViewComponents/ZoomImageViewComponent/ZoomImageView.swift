// The Swift Programming Language
// https://docs.swift.org/swift-book


import SwiftUI
import UIKit

public struct ZoomImageView: UIViewRepresentable {
    private var image: UIImage
    private var maximumZoomScale: CGFloat = 2.0
    private var minimumZoomScale: CGFloat = 1.0
    private var doubleTapZoomScale: CGFloat = 1.5
    private var showsHorizontalScrollIndicator: Bool = false
    private var showsVerticalScrollIndicator: Bool = false
    private var alwaysBounceVertical: Bool = false
    private var alwaysBounceHorizontal: Bool = false
    private var contentMode: UIView.ContentMode = .scaleAspectFit
    private var onDragEnd: ((UISwipeGestureRecognizer.Direction) -> Void)? = nil
    private var dragThreshold: CGFloat = 50.0
    
    public init(image: UIImage) {
        self.image = image
    }
    
    
    public func maximumZoomScale(_ scale: CGFloat) -> ZoomImageView {
        var newView = self
        newView.maximumZoomScale = scale
        return newView
    }
    
    public func minimumZoomScale(_ scale: CGFloat) -> ZoomImageView {
        var newView = self
        newView.minimumZoomScale = scale
        return newView
    }
    
    public func doubleTapZoomScale(_ scale: CGFloat) -> ZoomImageView {
        var newView = self
        newView.doubleTapZoomScale = scale
        return newView
    }
    
    public func showsHorizontalScrollIndicator(_ shows: Bool) -> ZoomImageView {
        var newView = self
        newView.showsHorizontalScrollIndicator = shows
        return newView
    }
    
    public func showsVerticalScrollIndicator(_ shows: Bool) -> ZoomImageView {
        var newView = self
        newView.showsVerticalScrollIndicator = shows
        return newView
    }
    
    public func alwaysBounceVertical(_ bounces: Bool) -> ZoomImageView {
        var newView = self
        newView.alwaysBounceVertical = bounces
        return newView
    }
    
    public func alwaysBounceHorizontal(_ bounces: Bool) -> ZoomImageView {
        var newView = self
        newView.alwaysBounceHorizontal = bounces
        return newView
    }
    
    public func contentMode(_ mode: UIView.ContentMode) -> ZoomImageView {
        var newView = self
        newView.contentMode = mode
        return newView
    }
    
    public func onDragEnd(threshold: CGFloat = 50.0, action: @escaping (UISwipeGestureRecognizer.Direction) -> Void) -> ZoomImageView {
        var newView = self
        newView.onDragEnd = action
        newView.dragThreshold = threshold
        return newView
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = max(maximumZoomScale, 1.0)
        scrollView.minimumZoomScale = 0.1 // Start with a safe minimum
        scrollView.zoomScale = 0.1 // Start with a safe minimum
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        scrollView.alwaysBounceVertical = alwaysBounceVertical
        scrollView.alwaysBounceHorizontal = alwaysBounceHorizontal
        scrollView.contentInsetAdjustmentBehavior = .automatic
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = contentMode
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        // Add custom drag gesture recognizer
        if onDragEnd != nil {
            let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
            panGesture.delegate = context.coordinator
            scrollView.addGestureRecognizer(panGesture)
        }
        
        context.coordinator.scrollView = scrollView
        context.coordinator.imageView = imageView
        context.coordinator.doubleTapZoomScale = doubleTapZoomScale
        context.coordinator.onDragEnd = onDragEnd
        context.coordinator.dragThreshold = dragThreshold
        context.coordinator.updateImageViewFrame(forceZoomReset: true)
        
        return scrollView
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.imageView?.image = image
        context.coordinator.updateImageViewFrame(forceZoomReset: false)
        context.coordinator.onDragEnd = onDragEnd
        context.coordinator.dragThreshold = dragThreshold
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        weak var scrollView: UIScrollView?
        weak var imageView: UIImageView?
        var doubleTapZoomScale: CGFloat = 2.0
        var onDragEnd: ((UISwipeGestureRecognizer.Direction) -> Void)?
        var dragThreshold: CGFloat = 50.0
        var initialImageCenter: CGPoint = .zero
        var dragDirection: UISwipeGestureRecognizer.Direction = .right
        var isDragging: Bool = false
        
        func updateImageViewFrame(forceZoomReset: Bool = false) {
            guard let scrollView = scrollView, let imageView = imageView, let image = imageView.image else { return }

            // Apply pending layout changes to make sure scrollView.bounds is accurate
            scrollView.layoutIfNeeded()

            // Only proceed if the scroll view has valid dimensions
            if scrollView.bounds.width <= 0 || scrollView.bounds.height <= 0 {
                // Schedule another attempt if the bounds aren't valid yet
                DispatchQueue.main.async { [weak self] in
                    self?.updateImageViewFrame(forceZoomReset: forceZoomReset)
                }
                return
            }
            
            // Only proceed if the image has valid dimensions
            if image.size.width <= 0 || image.size.height <= 0 {
                return
            }
            
            let boundsSize = scrollView.bounds.size
            let imageSize = image.size
            
            let widthScale = boundsSize.width / imageSize.width
            let heightScale = boundsSize.height / imageSize.height
            let minScale = min(widthScale, heightScale)
            
            // Ensure we never set a zero or negative scale
            let safeMinScale = max(minScale, 0.1)
            
            // Set the minimum zoom scale
            scrollView.minimumZoomScale = safeMinScale
            
            // Always reset to minimum zoom scale on initialization or when forced
            if forceZoomReset || abs(scrollView.zoomScale - 1.0) < 0.01 {
                scrollView.zoomScale = safeMinScale
            }
            
            // Update the image view's frame based on the current zoom scale
            let scaledImageSize = CGSize(
                width: imageSize.width * scrollView.zoomScale,
                height: imageSize.height * scrollView.zoomScale
            )
            imageView.frame = CGRect(origin: .zero, size: scaledImageSize)
            
            // Update the content size
            scrollView.contentSize = imageView.frame.size
            
            // Center the image
            centerImageView()
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
        
        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerImageView()
        }
        
        private func centerImageView() {
            guard let scrollView = scrollView, let imageView = imageView else { return }
            
            let boundsSize = scrollView.bounds.size
            var frameToCenter = imageView.frame
            
            frameToCenter.origin.x = max((boundsSize.width - frameToCenter.size.width) / 2, 0)
            frameToCenter.origin.y = max((boundsSize.height - frameToCenter.size.height) / 2, 0)
            
            imageView.frame = frameToCenter
        }
        
        @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            guard let scrollView = scrollView, let imageView = imageView else { return }
            
            if abs(scrollView.zoomScale - scrollView.minimumZoomScale) < 0.01 {
                // Get the location of the tap in the scroll view's coordinate space
                let tapPoint = sender.location(in: imageView)
                
                // Calculate the zoom rect
                let zoomRectWidth = scrollView.bounds.width / doubleTapZoomScale
                let zoomRectHeight = scrollView.bounds.height / doubleTapZoomScale
                
                // Create a rect centered at the tap point
                let zoomRect = CGRect(
                    x: tapPoint.x - (zoomRectWidth / 2),
                    y: tapPoint.y - (zoomRectHeight / 2),
                    width: zoomRectWidth,
                    height: zoomRectHeight
                )
                
                // Zoom to the rect
                scrollView.zoom(to: zoomRect, animated: true)
            } else {
                // If already zoomed in, zoom out to minimum scale
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            }
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let scrollView = scrollView, let imageView = imageView else { return }
            
            // Only handle the pan gesture when the image is at minimum zoom scale
            if scrollView.zoomScale > scrollView.minimumZoomScale + 0.01 {
                return
            }
            
            switch gesture.state {
            case .began:
                // Store the initial center of the image view
                initialImageCenter = imageView.center
                isDragging = true
                
                // Temporarily disable scrolling while dragging
                scrollView.isScrollEnabled = false
                
            case .changed:
                // Move the image view with the gesture
                let translation = gesture.translation(in: scrollView)
                imageView.center = CGPoint(
                    x: initialImageCenter.x + translation.x,
                    y: initialImageCenter.y + translation.y
                )
                
                // Determine the drag direction based on the translation
                let absX = abs(translation.x)
                let absY = abs(translation.y)
                
                if absX > absY {
                    dragDirection = translation.x > 0 ? .right : .left
                } else {
                    dragDirection = translation.y > 0 ? .down : .up
                }
                
            case .ended, .cancelled:
                // Get the final translation
                let translation = gesture.translation(in: scrollView)
                let absX = abs(translation.x)
                let absY = abs(translation.y)
                let dragDistance = max(absX, absY)
                
                // Determine the final direction based on the greatest movement
                if absX > absY {
                    dragDirection = translation.x > 0 ? .right : .left
                } else {
                    dragDirection = translation.y > 0 ? .down : .up
                }
                
                // Animate the image view back to its initial position
                UIView.animate(withDuration: 0.3) {
                    imageView.center = self.initialImageCenter
                } completion: { _ in
                    // Re-enable scrolling
                    scrollView.isScrollEnabled = true
                    self.isDragging = false
                    
                    // If the drag distance exceeds the threshold, call the closure
                    if dragDistance >= self.dragThreshold {
                        self.onDragEnd?(self.dragDirection)
                    }
                }
                
            default:
                scrollView.isScrollEnabled = true
                isDragging = false
                break
            }
        }
        
        // UIGestureRecognizerDelegate methods
        
        // This method determines whether our custom pan gesture should begin
        public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let scrollView = scrollView, let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
                return true
            }
            
            // Only allow our custom pan gesture when zoomed out
            if scrollView.zoomScale > scrollView.minimumZoomScale + 0.01 {
                return false
            }
            
            return true
        }
        
        // This method determines whether our gesture can work simultaneously with other gestures
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let scrollView = scrollView else { return false }
            
            // If we're zoomed in, let the scroll view's built-in gestures work normally
            if scrollView.zoomScale > scrollView.minimumZoomScale + 0.01 {
                return true
            }
            
            // If we're already dragging with our custom gesture, don't let other gestures interfere
            if isDragging {
                return false
            }
            
            // If the other gesture is the scroll view's pan gesture and we're zoomed out,
            // we want our custom pan gesture to take precedence
            if otherGestureRecognizer is UIPanGestureRecognizer &&
                otherGestureRecognizer.view is UIScrollView {
                return false
            }
            
            return true
        }
    }
}
