// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PureTextCore",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "PureTextCore",
            targets: ["PureTextCore"]
        ),
    ],
    targets: [
        .target(
            name: "PureTextCore",
            path: "Sources/PureTextCore"
        ),
    ]
)
