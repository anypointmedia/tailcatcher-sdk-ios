// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TailCatcherSdk",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TailCatcherSdk",
            targets: ["TailCatcherSdk"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TailCatcherSdk",
            dependencies: [
            ]
        ),
    ]
)
