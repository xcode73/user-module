// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "user-module",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "UserModule", targets: ["UserModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/xcode73/feather-core", .branch("test-dev")),
        .package(url: "https://github.com/xcode73/user-objects", .branch("test-dev")),
    ],
    targets: [
        .target(name: "UserModule",
                dependencies: [
                    .product(name: "UserObjects", package: "user-objects"),
                    .product(name: "Feather", package: "feather-core"),
                ],
                resources: [
//                    .copy("Bundle"),
                ]),
    ]
)
