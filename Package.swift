// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DevLauncher",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.2.0")
    ],
    targets: [
        .executableTarget(
            name: "DevLauncher",
            dependencies: [
                "KeyboardShortcuts"
            ],
            path: "Sources/DevLauncher"
        ),
        .testTarget(
            name: "DevLauncherTests",
            dependencies: ["DevLauncher"]
        ),
    ]
)
