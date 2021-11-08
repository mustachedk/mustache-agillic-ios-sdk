// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "AgillicSDK",
  platforms: [.iOS(.v11)],
  products: [
    .library(name: "AgillicSDK", targets: ["AgillicSDK"]),
  ],
  dependencies: [
   .package(url: "https://github.com/snowplow/snowplow-objc-tracker", .upToNextMajor(from: "1.3.0"))
 ],
  targets: [
    .target(
        name: "AgillicSDK",
        dependencies: ["SnowplowTracker"],
        path: "src/AgillicSDK")
  ]
)
