// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CineScopeCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "CineScopeCore",
            type: .dynamic,
            targets: ["CineScopeCore"]
        )
    ],
    targets: [
        .target(
            name: "CineScopeCore",
            resources: [
                .process("Fixtures")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "CineScopeCoreTests",
            dependencies: ["CineScopeCore"],
            resources: [
                .process("Fixtures")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
