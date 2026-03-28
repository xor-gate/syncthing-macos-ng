// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "syncthing-macos",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "STSwiftLibrary", targets: ["STSwiftLibrary"])
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
        .executableTarget(
            name: "syncthing-macos-exe",
            dependencies: ["STSwiftLibrary"],
            path: "Sources/STMacOSApplication",
            //resources: [
            //    .process("Resources")
            //]
        ),
    ]
)
