// swift-tools-version: 5.9
import PackageDescription
#if canImport(AppleProductTypes)
import AppleProductTypes
#endif

private let packageProducts: [Product] = {
#if canImport(AppleProductTypes)
    return [
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
    ]
#else
    // Fall back to a library product so the manifest still resolves when
    // Apple-only helpers such as `AppleProductTypes` are unavailable (e.g.,
    // on non-Xcode Swift toolchains). Xcode 15+ will ignore this branch and
    // expose the iOS application scheme as usual.
    return [
        .library(
            name: "GomokuIOS",
            targets: ["GomokuIOS"]
        )
    ]
#endif
}()

let package = Package(
    name: "GomokuIOS",
    platforms: [
        .iOS(.v16)
    ],
    products: packageProducts,
    targets: [
        .executableTarget(
            name: "GomokuIOS",
            path: "GomokuIOS"
        )
    ]
)
