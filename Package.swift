// swift-tools-version: 5.9
import Foundation
import PackageDescription

let package = Package(
    name: "STMacOSApplication",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "STMacOSApplication", targets: ["STMacOSApplication"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.9.0"),
    ],
    targets: [
        .executableTarget(
            name: "STMacOSApplication",
            dependencies: ["Sparkle"],
            path: "Sources",
            //resources: [
            //    .process("Resources")
            //]
        ),
    ]
)
