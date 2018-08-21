// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "guaka-cli",
    dependencies: [
        .package(url: "https://github.com/nsomar/Guaka.git", from: "0.0.0"),
        .package(url: "https://github.com/getGuaka/Env.git", from: "0.0.0"),
        .package(url: "https://github.com/getGuaka/FileUtils.git", from: "0.0.0"),
    ],
    targets: [
      .target(name: "guaka-cli", dependencies: ["GuakaClILib"]),
      .target(name: "Swiftline"),
      .target(name: "GuakaClILib", dependencies: ["Swiftline"]),
    ],
    swiftLanguageVersions: [4]
)
