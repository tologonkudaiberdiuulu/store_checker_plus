// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "store_checker_plus",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "store-checker-plus", targets: ["store_checker_plus"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "store_checker_plus",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                // The plugin collects no data and uses no required reason APIs. The manifest
                // states that explicitly so it shows up in the app's privacy report.
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
