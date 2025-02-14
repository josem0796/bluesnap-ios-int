// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BluesnapSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12), // UIKit is available on iOS
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BluesnapSDK",
            targets: ["BluesnapSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(url: "https://github.com/Kount/kount-ios-swift-package", .upToNextMajor(from: "4.1.9"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BluesnapSDK",
            dependencies: ["CardinalMobile"],
            exclude: ["include/module.modulemap"],
            cSettings: [
                .headerSearchPath("include")
            ]
        ),
        .binaryTarget(name: "CardinalMobile", path: "Frameworks/XCFrameworks/CardinalMobile.xcframework")

    ]
)
