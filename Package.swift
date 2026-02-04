// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = Package(
    name: "Server-Side-Swift-Runtime",
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Server-Side-Swift-Runtime",
            dependencies: ["Scheduler", "CShims"]),
        .target(
            name: "CShims",
            path: "Sources/CShims"),
        .target(
            name: "Scheduler",
            dependencies: ["CShims"],
            path: "Sources/Scheduler")
    ]
)
