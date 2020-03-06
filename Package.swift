// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "JupyterTool",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(
            name: "JupyterTool",
            targets: ["JupyterTool"]
        ),
        .library(
            name: "JupyterKit",
            targets: ["JupyterKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pvieito/LoggerKit.git", .branch("master")),
        .package(url: "https://github.com/pvieito/FoundationKit.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "JupyterTool",
            dependencies: ["LoggerKit", "JupyterKit", .product(name: "ArgumentParser", package: "swift-argument-parser")],
            path: "JupyterTool"
        ),
        .target(
            name: "JupyterKit",
            dependencies: ["FoundationKit"],
            path: "JupyterKit"
        ),
        .testTarget(
            name: "JupyterKitTests",
            dependencies: ["JupyterKit"]
        )
    ]
)
