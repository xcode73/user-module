// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "user-module",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .library(name: "UserModule", targets: ["UserModule"]),
        .library(name: "UserRestKit", targets: ["UserRestKit"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/feathercms/feather-core", .branch("dev")),
        .package(path: "../feather-core"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"),
        .package(url: "https://github.com/binarybirds/liquid-local-driver", from: "1.3.0"),
        .package(url: "https://github.com/binarybirds/mail-aws-driver", from: "0.0.1"),
    ],
    targets: [
        .executableTarget(name: "UserApp", dependencies: [
            .target(name: "UserModule"),

            .product(name: "Feather", package: "feather-core"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "LiquidLocalDriver", package: "liquid-local-driver"),
            .product(name: "MailAwsDriver", package: "mail-aws-driver"),
        ]),
        .target(name: "UserModule",
                dependencies: [
                    .target(name: "UserRestKit"),
                    .product(name: "Feather", package: "feather-core"),
                ],
                resources: [
                    .copy("Bundle"),
                ]),
        .target(name: "UserRestKit", dependencies: [
            .product(name: "FeatherRestKit", package: "feather-core"),
        ]),
    ]
)
