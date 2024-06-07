// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "user-module",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "UserModule", targets: ["UserModule"])
    ],
    dependencies: [
        //local
        .package(path: "../feather-core"),
        .package(path: "../user-objects"),
//        .package(url: "https://github.com/xcode73/feather-core.git", branch: "test-dev"),
//        .package(url: "https://github.com/xcode73/user-objects.git", branch: "test-dev")
    ],
    targets: [
        .target(name: "UserModule",
                dependencies: [
                    .product(name: "UserObjects", package: "user-objects"),
                    .product(name: "Feather", package: "feather-core")
                ],
                resources: [
//                    .copy("Bundle")
                ]),
    ],
    swiftLanguageVersions: [.v5]
)
