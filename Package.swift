// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZoomImageView",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ZoomImageView",
            targets: ["ZoomImageView"]),
    ],
    targets: [
        .target(
            name: "ZoomImageView",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ZoomImageViewTests",
            dependencies: ["ZoomImageView"]
        ),
    ]
)

