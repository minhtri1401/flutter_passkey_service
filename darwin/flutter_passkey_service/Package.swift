// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_passkey_service",
    platforms: [
        .iOS("16.0"),
        .macOS("13.0")
    ],
    products: [
        // Underscores become hyphens in the library name, per Flutter's plugin template.
        .library(name: "flutter-passkey-service", targets: ["flutter_passkey_service"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_passkey_service",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
