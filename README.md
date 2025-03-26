<div align="center">
  <img width="300" height="300" src="/assets/icon.png" alt="ZoomImageView Logo">
  <h1><b>ZoomImageView</b></h1>
  <p>
ZoomImageViewPackage is a SwiftUI component that provides an image view with zoom and pan functionality. It's built using UIScrollView and UIImageView as a UIViewRepresentable, allowing for easy integration into SwiftUI applications.
    <br>
    <i>Compatible with iOS 14.0 and later</i>
  </p>
</div>

<div align="center">
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-5.9%20%7C%206-orange.svg" alt="Swift Version">
  </a>
  <a href="https://www.apple.com/ios/">
    <img src="https://img.shields.io/badge/iOS-14%2B-blue.svg" alt="iOS">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
  </a>
</div>

## **Overview**

`ZoomImageViewPackage` is a SwiftUI component that provides an image view with zoom and pan functionality. It's built using `UIScrollView` and `UIImageView` as a `UIViewRepresentable`, allowing for easy integration into SwiftUI applications.


![Example](/assets/example.gif)

## **Installation**

### Swift Package Manager

1. In Xcode, navigate to **File > Add Packages...**
2. Enter the repository URL:  
   `https://github.com/ronaldo-avalos/ZoomImageView`
3. Follow the prompts to add the package to your project.

---



## **Usage**
Below I show how to call the component for its use, it has default parameters but you can modify them.

```swift
import SwiftUI
import ZoomImageViewPackage

struct ContentView: View {
    let imageName = "your_image_name" // Replace with your image name

    var body: some View {
        if let image = UIImage(named: imageName) {
            ZoomImageView(image: image)
                .maximumZoomScale(5.0)
                .minimumZoomScale(0.5)
                .showsHorizontalScrollIndicator(true)
                .alwaysBounceVertical(true)
                .doubleTapZoomScale(2.0)
                .frame(width: 300, height: 200)
                .border(Color.gray) // Optional to see the component's bounds
        } else {
            Text("Failed to load image: \(imageName)")
        }
    }
}

#Preview {
    ContentView()
}

```

## **Customizable Parameters**

You can customize the behavior of `ZoomImageView` using the following modifiers:

- `maximumZoomScale(_: CGFloat)`: Sets the maximum zoom scale allowed.
- `minimumZoomScale(_: CGFloat)`: Sets the minimum zoom scale allowed.
- `doubleTapZoomScale(_: CGFloat)`: Defines the zoom scale on a double tap.
- `showsHorizontalScrollIndicator(_: Bool)`: Shows or hides the horizontal scroll indicator.
- `showsVerticalScrollIndicator(_: Bool)`: Shows or hides the vertical scroll indicator.
- `alwaysBounceVertical(_: Bool)`: Enables or disables vertical bouncing even if there's no content to scroll.
- `alwaysBounceHorizontal(_: Bool)`: Enables or disables horizontal bouncing even if there's no content to scroll.
- `contentMode(_: UIView.ContentMode)`: Sets the content mode of the image (e.g., .scaleAspectFit, .scaleAspectFill, etc.).

## **Contributions**
 Contributions are welcome. If you encounter any issues or have suggestions, please open an issue or submit a pull request.   

# Donate

Show your appreciation by donating me a coffee. Thank you very much!

<a href="https://buymeacoffee.com/ronaldo_avalos" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="160">
</a>


## **Author**
@Roandlo Avalos github.com/ronaldo-avalos

## **License**
RenderMeThis is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

