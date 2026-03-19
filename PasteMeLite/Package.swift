// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PasteMeLite",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PasteMeLite", targets: ["PasteMeLite"])
    ],
    targets: [
        .executableTarget(
            name: "PasteMeLite",
            path: "Sources/PasteMeLite"
        )
    ]
)
