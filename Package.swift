// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "CStorage",
    platforms: [
        .iOS(.v14),  // или минимальная версия, которая вам нужна
    ],
    products: [
        .library(
            name: "CStorage",
            targets: ["CStorage"]),
    ],
    targets: [
        .target(
            name: "CStorage",
            dependencies: []),
        .testTarget(
            name: "CStorageTests",
            dependencies: ["CStorage"]),
    ]
)
