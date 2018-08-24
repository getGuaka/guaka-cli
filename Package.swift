// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "guaka-cli",
    dependencies: [
        .package(url: "https://github.com/nsomar/Guaka.git", from: "0.0.0"),
        .package(url: "https://github.com/getGuaka/FileUtils.git", from: "0.0.0"),
        .package(url: "https://github.com/getGuaka/StringScanner.git", from: "0.0.0"),
    ],
    targets: [
        .target(name: "guaka-cli", dependencies: ["Guaka", "GuakaClILib"]),
        .target(name: "Swiftline", dependencies: ["StringScanner"]),
        .target(name: "GuakaClILib", dependencies: ["FileUtils", "StringScanner", "Swiftline"]),

        .testTarget(name: "GuakaClILibTests", dependencies: ["GuakaClILib"]),
    ],
    swiftLanguageVersions: [4]
)
