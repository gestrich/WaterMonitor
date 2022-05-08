// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WaterMonitor",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "WaterMonitorClient",
            targets: ["WaterMonitorClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", .upToNextMajor(from:"0.4.0")),
        .package(name: "AWSSDKSwift", url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "WaterMonitor",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime"),
                .product(name: "DynamoDB", package: "AWSSDKSwift"),
                .target(name: "WaterMonitorClient")
            ]),
        .target(
            name: "WaterMonitorClient",
            dependencies: [
            ]),
        .testTarget(
            name: "WaterMonitorTests",
            dependencies: [
                .target(name: "WaterMonitor"),
                .product(name: "AWSLambdaTesting", package: "swift-aws-lambda-runtime"),
            ]),
        .testTarget(
            name: "WaterMonitorClientTests",
            dependencies: [
                .target(name: "WaterMonitorClient"),
            ]),
    ]
)
