// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GomokuIOS",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "GomokuIOS",
            targets: ["GomokuIOS"],
            bundleIdentifier: "com.example.gomoku",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder,
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [
                .portrait,
                .portraitUpsideDown,
                .landscapeLeft,
                .landscapeRight
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "GomokuIOS",
            path: "GomokuIOS"
        )
    ]
)
