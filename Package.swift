// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "guaka-cli",
    dependencies: [
        .package(url: "https://github.com/nsomar/Guaka.git", from: "0.0.0"),
        .package(url: "https://github.com/getGuaka/Colorizer.git", from: "0.1.0"),
        .package(url: "https://github.com/getGuaka/FileUtils.git", from: "0.0.0"),
        .package(url: "https://github.com/getGuaka/Run.git", from: "0.1.0"),
        .package(url: "https://github.com/getGuaka/StringScanner.git", from: "0.0.0"),
    ],
    targets: [
        .target(name: "guaka-cli", dependencies: ["Guaka", "GuakaClILib"]),
        .target(name: "GuakaClILib", dependencies: ["Colorizer", "FileUtils", "Run", "StringScanner"]),

        .testTarget(name: "GuakaClILibTests", dependencies: ["GuakaClILib"]),
    ],
    swiftLanguageVersions: [4]
)
