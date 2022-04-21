// swift-tools-version:5.3
import PackageDescription

let tag = "0.0.7"
let checksum = "248516a8014f910ab786eb31f48cb2fced2fb527d3378520cf1e13b1324d38b9"
let url = "https://github.com/jurvis/libwally-swift/releases/download/\(tag)/LibWallySwift.xcframework.zip"

let package = Package(
    name: "LibWallySwift",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "LibWallySwift",
            targets: ["LibWallySwift"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "LibWallySwift",
            url: url,
            checksum: checksum
        )
    ]
)
