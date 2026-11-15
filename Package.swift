// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "drago",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "drago", targets: ["drago"]),
    ],
    targets: [
        // Pure logic (option parsing, path handling) — testable without AppKit.
        .target(name: "DragoCore"),
        .executableTarget(name: "drago", dependencies: ["DragoCore"]),
        .testTarget(name: "DragoCoreTests", dependencies: ["DragoCore"]),
    ]
)
