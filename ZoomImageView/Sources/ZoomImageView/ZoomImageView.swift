// The Swift Programming Language
// https://docs.swift.org/swift-book


import SwiftUI
import UIKit

public struct ZoomImageView: UIViewRepresentable {
    private var image: UIImage
    private var maximumZoomScale: CGFloat = 4.0
    private var minimumZoomScale: CGFloat = 1.0
    private var doubleTapZoomScale: CGFloat = 2.0
    private var showsHorizontalScrollIndicator: Bool = false
    private var showsVerticalScrollIndicator: Bool = false
    private var alwaysBounceVertical: Bool = false
    private var alwaysBounceHorizontal: Bool = false
    private var contentMode: UIView.ContentMode = .scaleAspectFit

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

    public func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.minimumZoomScale = minimumZoomScale
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

        context.coordinator.scrollView = scrollView
        context.coordinator.imageView = imageView
        context.coordinator.doubleTapZoomScale = doubleTapZoomScale

        return scrollView
    }

    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        DispatchQueue.main.async {
                context.coordinator.imageView?.image = image
                context.coordinator.updateImageViewFrame()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator: NSObject, UIScrollViewDelegate {
        weak var scrollView: UIScrollView?
        weak var imageView: UIImageView?
        var doubleTapZoomScale: CGFloat = 2.0

        func updateImageViewFrame() {
            guard let scrollView = scrollView, let imageView = imageView, let image = imageView.image else { return }

            let boundsSize = scrollView.bounds.size
            let imageSize = image.size

            let widthScale = boundsSize.width / imageSize.width
            let heightScale = boundsSize.height / imageSize.height
            let minScale = min(widthScale, heightScale)

            scrollView.minimumZoomScale = minScale
            scrollView.zoomScale = minScale

            let scaledImageSize = CGSize(width: imageSize.width * minScale, height: imageSize.height * minScale)
            imageView.frame = CGRect(origin: .zero, size: scaledImageSize)

            scrollView.contentSize = imageView.frame.size

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
            guard let scrollView = scrollView else { return }

            let newZoomScale = (scrollView.zoomScale == scrollView.minimumZoomScale) ? doubleTapZoomScale : scrollView.minimumZoomScale

            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 1,
                options: .curveEaseInOut,
                animations: {
                    scrollView.setZoomScale(newZoomScale, animated: false)
                },
                completion: nil
            )
        }
    }
}
