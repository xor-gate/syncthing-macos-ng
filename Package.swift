// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "syncthing-macos",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "STSwiftLibrary", targets: ["STSwiftLibrary"]),
        .library(name: "STMacOSApplication", targets: ["STMacOSApplication"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.9.0"),
    ],
    targets: [
	.target(
	    name: "STSwiftLibrary",
	    dependencies: [
        	.product(name: "Sparkle", package: "Sparkle")
	    ],
            path: "Sources/STSwiftLibrary",
	),
    .target(
        name: "STMacOSApplication",
        dependencies: ["STSwiftLibrary"], // Link to the library so you can test it
            path: "Sources/STMacOSApplication",
    ),
        .executableTarget(
            name: "syncthing-macos-exe",
            dependencies: ["STMacOSApplication"],
            path: "Sources/STMacOSApplicationMain",
            //resources: [
            //    .process("Resources")
            //]
        ),
    .testTarget(
                name: "STSwiftLibraryTests",
                dependencies: ["STSwiftLibrary"], // Link to the library so you can test it
                path: "Tests/STSwiftLibraryTests"
            ),
    ]
)
