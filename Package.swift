// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftZST_Test",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/felixhandte/zstd.git", .branch("modulemap-improvements"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SwiftZST",
            dependencies: [ .product(name: "libzstd", package: "zstd") ],
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftZST_Tests",
            dependencies: [ "SwiftZST" ],
            path: "Tests",
            cSettings: [
                .unsafeFlags([
                    "-DZSTDLIB_VISIBLE=__attribute__ ((visibility (\"default\")))",
                    "-DZSTD_CLEVEL_DEFAULT=3",
                    "-DZDICTLIB_VISIBILITY=__attribute__ ((visibility (\"default\")))",
                    "-DZSTDERRORLIB_VISIBILITY=__attribute__ ((visibility (\"default\")))"
                ])
            ]
        )
    ]
)
