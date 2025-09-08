// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MiraTool",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "mira", targets: ["MiraTool"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MiraTool",
            dependencies: []
        ),
        .testTarget(
            name: "MiraToolTests",
            dependencies: ["MiraTool"]
        ),
    ]
)