//
//  File.swift
//  ZoomImageView
//
//  Created by amolonus on 26/03/2025.
//

import SwiftUI
import UIKit

struct PreviewView: App {
    var body: some Scene {
        WindowGroup {
            mainView
        }
    }
    var mainView: some View {
        ImageLoadingView(imageURL: MockImageModel.landscapeImage) {
            print("")
        }
    }
    
}

struct RootView: View {
    @State private var imageURL: URL?
    var body: some View {
        VStack {
            AsyncImage(url: MockImageModel.landscapeImage) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        //Tap to open preview
                        imageURL = MockImageModel.landscapeImage
                    }
            } placeholder: {
                Rectangle()
                    .foregroundStyle(Color.blue.opacity(0.3))
                    .frame(height: 300)
            }
        }
        .fullScreenCover(item: $imageURL, content: { imageURL in
            ImageLoadingView(imageURL: imageURL) {
                //Dismissing preview
                self.imageURL = nil
            }
        })
    }
}
#Preview("Live Demo") {
    RootView()
}

#Preview("Async Image - Landscape preview") {
    ImageLoadingView(imageURL: MockImageModel.landscapeImage) {
        //Action passed here will be applied for both swipe-down gesture or button press
        print("Image View Dismissed")
    }
}

#Preview("Async Image - Portrait preview") {
    ImageLoadingView(imageURL: MockImageModel.portraitImage) {
        //Action passed here will be applied for both swipe-down gesture or button press
        print("Image View Dismissed")
    }
}

#Preview("Local Image -  Portrait preview") {
    if let image = UIImage(named: "localImage", in: .module, with: nil) {
        ImageLoadingView(image: image) {
            print("dismissed")
        }
    } else {
        Text("Image not found")
    }
}

extension URL: Identifiable {
    public var id: String {
        UUID().uuidString
    }
}
