// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BlossomColorPicker",
    platforms: [
        .macOS(.v13),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "BlossomColorPicker",
            targets: ["BlossomColorPicker"],
        )
    ],
    targets: [
        .target(
            name: "BlossomColorPickerCore",
            resources: [.process("Resources")],
        ),
        .target(
            name: "BlossomColorPicker",
            dependencies: ["BlossomColorPickerCore"],
        ),
    ],
)
