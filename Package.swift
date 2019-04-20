// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Advance",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "Advance",
            targets: ["Advance"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Advance",
            dependencies: []),
        .testTarget(
            name: "AdvanceTests",
            dependencies: ["Advance"]),
    ],
    swiftLanguageVersions: [.v5]
)
