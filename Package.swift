
import PackageDescription

let package = Package(
    name: "BluesnapSDK",
    products: [
        .library(
            name: "BluesnapSDK",
            targets: ["BluesnapSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BluesnapSDK",
            dependencies: []),
        .testTarget(
            name: "BluesnapSDKTests",
            dependencies: ["BluesnapSDKTests"]),
    ]
)

