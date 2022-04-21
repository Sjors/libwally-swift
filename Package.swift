// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LibWallySwift",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "LibWally",
            targets: ["LibWally"]
        )
    ],
    targets: [
        .target(
            name: "LibWally",
            dependencies: ["LibWallyCore"],
            path: "LibWally"
        ),
        .target(
            name: "LibWallyCore",
            path: "LibWallyCore"
        ),
        .testTarget(
            name: "LibWallyTests",
            dependencies: ["LibWally"],
            path: "LibWallyTests"
        )
    ]
)
