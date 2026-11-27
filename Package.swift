// swift-tools-version: 6.3

import PackageDescription

// Every platform without Apple's simd module. NucleantSIMD re-exports
// NucleantSIMDPortable on these and Apple's simd everywhere else.
let portablePlatforms: [Platform] = [.linux, .android, .windows, .wasi, .openbsd]

let package = Package(
    name: "NucleantSIMD",
    products: [
        // `import NucleantSIMD`: Apple's simd on Apple platforms, the same
        // API written in Swift on the others.
        .library(
            name: "NucleantSIMD",
            targets: ["NucleantSIMD"]
        ),
    ],
    targets: [
        .target(
            name: "NucleantSIMD",
            dependencies: [
                .target(name: "NucleantSIMDPortable", condition: .when(platforms: portablePlatforms)),
            ]
        ),
        // The simd API written in Swift, for the platforms above.
        .target(
            name: "NucleantSIMDPortable"
        ),
        // `import NucleantSIMD` on each platform: Apple's simd on Apple,
        // NucleantSIMDPortable on the others.
        .testTarget(
            name: "NucleantSIMDTests",
            dependencies: ["NucleantSIMD"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
