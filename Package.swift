// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "user-module",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .library(name: "UserModule", targets: ["UserModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/feathercms/feather-core", .branch("dev")),
        .package(url: "https://github.com/feathercms/user-objects", .branch("main")),
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
