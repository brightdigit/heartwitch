// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Heartwitch",
    products: [
        .library(name: "Heartwitch", targets: ["Heartwitch"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/brightdigit/vapor.git",  .branch("4-websocket-fix")),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha.2"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-alpha.3"),
        .package(url: "https://github.com/brightdigit/Base32Crockford.git", Package.Dependency.Requirement.branch("master"))
    ],
    targets: [
        .target(name: "Heartwitch", dependencies: []),
        .target(name: "HeartwitchServer", dependencies: ["Heartwitch", "Fluent", "FluentSQLiteDriver", "Vapor", "Base32Crockford"]),
        .target(name: "Run", dependencies: ["HeartwitchServer"]),
        .testTarget(name: "AppTests", dependencies: ["HeartwitchServer"])
    ]
)

