// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftUITranslator",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "SwiftUITranslator",
            targets: ["SwiftUITranslator"]
        )
    ],
    dependencies: [
        // Add external dependencies here, such as networking libraries
    ],
    targets: [
        .executableTarget(
            name: "SwiftUITranslator",
            dependencies: [],
            path: "SwiftUITranslator",
            exclude: [
                "SwiftUITranslator.entitlements"
            ]
        )
    ]
)
