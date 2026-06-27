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
    dependencies: [
        .package(path: "Packages/PureTextCore"),
    ],
    targets: [
        .executableTarget(
            name: "PureText",
            dependencies: [
                .product(name: "PureTextCore", package: "PureTextCore"),
            ],
            path: "Sources/PureText"
        ),
    ]
)
