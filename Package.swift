// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MJLLogger",
	platforms: [ .macOS(.v10_13) ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MJLLogger",
            targets: ["MJLLogger"]),
    ],
    dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MJLLogger",
            dependencies: ["Logging"]),
        .testTarget(
            name: "MJLLoggerTests",
            dependencies: ["MJLLogger"]),
    ]
)
