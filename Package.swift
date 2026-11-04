// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Reachline",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Reachline", targets: ["Reachline"])
    ],
    targets: [
        .executableTarget(
            name: "Reachline",
            path: "Sources/Reachline"
        ),
        .testTarget(
            name: "ReachlineTests",
            dependencies: ["Reachline"]
        )
    ]
)