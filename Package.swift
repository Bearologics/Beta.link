// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "BetaLink",
    products: [
        .executable(name: "BetaLink", targets: ["BetaLink"])
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.7.0"),
        .package(name: "SplashPublishPlugin", url: "https://github.com/kimar/SplashPublishPlugin.git", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "BetaLink",
            dependencies: ["Publish", "SplashPublishPlugin"]
        )
    ]
)
