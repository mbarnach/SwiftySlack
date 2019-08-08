// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftySlack",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftySlack",
            targets: ["SwiftySlack"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
      .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.0"),
      .package(url: "https://github.com/IBM-Swift/SwiftyRequest", from: "2.1.1"),
      .package(url: "https://github.com/google/promises", from: "1.2.8"),
      
      // Testing dependencies
         .package(url: "https://github.com/Quick/Nimble", from: "8.0.2"),
         .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: Version("2.0.0-beta.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftySlack",
            dependencies: ["SwiftyRequest", "SwiftyJSON", "Promises"]),
        .testTarget(
            name: "SwiftySlackTests",
            dependencies: ["SwiftySlack", "Nimble", "SwiftyJSON", "SwiftyRequest", "CwlPreconditionTesting"]),
    ]
)
