// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Advance",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
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
