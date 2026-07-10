// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AcousticIdleTachometer",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AcousticIdleTachometerCore",
            targets: ["AcousticIdleTachometerCore"]
        )
    ],
    targets: [
        .target(
            name: "AcousticIdleTachometerCore"
        ),
        .testTarget(
            name: "AcousticIdleTachometerCoreTests",
            dependencies: ["AcousticIdleTachometerCore"]
        )
    ]
)
