// swift-tools-version:5.3
import PackageDescription

let tag = "0.0.7"
let checksum = "62aca7cefdf59cfe96d152e12cfd56387e9960e99523527ff478508f70ac25da"
let url = "https://github.com/jurvis/libwally-swift/releases/download/\(tag)/LibWally.xcframework.zip"

let package = Package(
    name: "LibWally",
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
        .binaryTarget(
            name: "LibWally",
            url: url,
            checksum: checksum
        )
    ]
)
