// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SwiftPong",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "SwiftPong",
            path: "Sources/SwiftPong"
        )
    ]
)
