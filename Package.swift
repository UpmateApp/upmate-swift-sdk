// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UpMate",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UpMate",
            targets: ["UpMate"]),
    ],
    dependencies: [
        // Declare the KeychainAccess package dependency
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UpMate",
            dependencies: [
                // Add KeychainAccess as a dependency for the UpMate target
                .product(name: "KeychainAccess", package: "KeychainAccess")
            ]
        ),
        .testTarget(
            name: "UpMateTests",
            dependencies: ["UpMate"]),
    ]
)
