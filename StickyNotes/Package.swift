// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StickyNotes",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "StickyNotesCore", targets: ["StickyNotesCore"]),
        .executable(name: "StickyNotes", targets: ["StickyNotesApp"]),
        .executable(name: "GenerateInfoPlist", targets: ["GenerateInfoPlist"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.1"),
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "StickyNotesCore",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
            ],
            path: "Sources/StickyNotesCore"
        ),
        .executableTarget(
            name: "StickyNotesApp",
            dependencies: [
                "StickyNotesCore",
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
            ],
            path: "Sources/StickyNotesApp"
        ),
        .executableTarget(
            name: "GenerateInfoPlist",
            dependencies: ["StickyNotesCore"],
            path: "Sources/GenerateInfoPlist"
        ),
        .testTarget(
            name: "StickyNotesCoreTests",
            dependencies: ["StickyNotesCore"],
            path: "Tests/StickyNotesCoreTests"
        ),
    ]
)
