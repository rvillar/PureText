// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PureText",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "PureText",
            targets: ["PureText"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "PureText",
            path: "Sources/PureText"
        ),
    ]
)
