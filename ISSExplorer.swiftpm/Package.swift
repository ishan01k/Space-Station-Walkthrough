// swift-tools-version: 6.2
import PackageDescription
import AppleProductTypes
let package = Package(
    name: "AstroMe",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "AstroMe",
            targets: ["AppModule"],
            bundleIdentifier: "com.issexplorer.app",
            teamIdentifier: "59J2DT7UL3",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .rocket),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad
            ],
            supportedInterfaceOrientations: [
                .landscapeLeft,
                .landscapeRight
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
