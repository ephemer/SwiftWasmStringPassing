// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftWasmStringPassing",
    products: [
        .executable(
            name: "SwiftWasmStringPassing",
            targets: ["SwiftWasmStringPassing"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/flowkey/swift-extras-json.git", branch: "embedded")
    ],
    targets: [
        .executableTarget(name: "SwiftWasmStringPassing", dependencies: [.product(name: "ExtrasJSON", package: "swift-extras-json")])
    ]
)
