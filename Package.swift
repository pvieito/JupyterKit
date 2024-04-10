// swift-tools-version:5.7

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
        .package(url: "git@github.com:pvieito/LoggerKit.git", branch: "master"),
        .package(url: "git@github.com:pvieito/FoundationKit.git", branch: "master"),
        .package(url: "git@github.com:pvieito/PythonKit.git", branch: "master"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "JupyterTool",
            dependencies: [
                "LoggerKit",
                "JupyterKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "JupyterTool"
        ),
        .target(
            name: "JupyterKit",
            dependencies: [
                "FoundationKit",
                "PythonKit",
            ],
            path: "JupyterKit"
        ),
        .testTarget(
            name: "JupyterKitTests",
            dependencies: ["JupyterKit"]
        )
    ]
)
