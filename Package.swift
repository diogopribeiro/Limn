// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Limn",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .watchOS(.v4),
        .tvOS(.v11),
    ],
    products: [
        .library(
            name: "Limn",
            targets: ["Limn"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "Limn",
            dependencies: []
        ),
        .testTarget(
            name: "LimnTests",
            dependencies: ["Limn"]
        ),
    ]
)
