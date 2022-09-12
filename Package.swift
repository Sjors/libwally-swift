// swift-tools-version:5.3
import PackageDescription

let tag = "0.0.7"
let checksum = "f2d8bbf4b6cf3cf4f4063b6a15a84648d78a3c7214f8836182b9f83ed8a2a595"
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
