// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TaskSequencer",
    platforms: [
        .iOS(.v13), // Minimum iOS version
        .macOS(.v10_15), // Adjust as needed for macOS
        .watchOS(.v6), // Adjust as needed for watchOS
        .tvOS(.v13) // Adjust as needed for tvOS
    ],
    products: [
        .library(
            name: "TaskSequencer",
            targets: ["TaskSequencer"]),
    ],
    targets: [
        .target(
            name: "TaskSequencer"),
        .testTarget(
            name: "TaskSequencerTests",
            dependencies: ["TaskSequencer"]),
    ]
)
