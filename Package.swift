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
        .package(url: "https://github.com/feathercms/feather-api", .branch("main")),
        .package(url: "https://github.com/feathercms/user-api", .branch("main")),
    ],
    targets: [
        .target(name: "UserModule",
                dependencies: [
                    .product(name: "FeatherApi", package: "feather-api"),
                    .product(name: "UserApi", package: "user-api"),
                    .product(name: "Feather", package: "feather-core"),
                ],
                resources: [
//                    .copy("Bundle"),
                ]),
    ]
)
