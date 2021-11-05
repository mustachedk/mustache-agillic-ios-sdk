// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "MustacheAgillicSDK",
  platforms: [.iOS(.v11)],
  products: [
    .library(name: "MustacheAgillicSDK", targets: ["MustacheAgillicSDK"]),
  ],
  dependencies: [
   .package(url: "https://github.com/snowplow/snowplow-objc-tracker", .upToNextMajor(from: "1.3.0"))
 ],
  targets: [
    .target(
        name: "MustacheAgillicSDK",
        dependencies: ["SnowplowTracker"],
        path: "src/MustacheAgillicSDK")
  ]
)
