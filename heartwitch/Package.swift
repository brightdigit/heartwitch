// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "heartwitch",
    products: [
        .library(name: "heartwitch-server", targets: ["App"]),
        .library(name: "heartwitch", targets: ["App"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/websocket.git", from: "1.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "WebSocket", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .target(name: "heartwitch"),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

