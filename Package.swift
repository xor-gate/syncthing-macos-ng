// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "syncthing-macos",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "STSwiftLibrary", targets: ["STSwiftLibrary"]),
                .executable(
                    name: "STLoginHelper",
                    targets: ["STLoginHelper"])
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
            name: "Syncthing",
            dependencies: ["STMacOSApplication"],
            path: "Sources/STMacOSApplicationMain",
            //resources: [
            //    .process("Resources")
            //]
        ),
                .executableTarget(
                    name: "STLoginHelper",
                    dependencies: [],
                    path: "Sources/STLoginHelperMain"),
    .testTarget(
                name: "STSwiftLibraryTests",
                dependencies: ["STSwiftLibrary"], // Link to the library so you can test it
                path: "Tests/STSwiftLibraryTests"
            ),
    ]
)
