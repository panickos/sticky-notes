import Foundation
import StickyNotesCore

guard CommandLine.arguments.count >= 2 else {
    fputs("usage: GenerateInfoPlist <output-path>\n", stderr)
    exit(1)
}

let outputPath = CommandLine.arguments[1]
let url = URL(fileURLWithPath: outputPath, isDirectory: false)
try InfoPlistGenerator.writePlist(for: .v1, to: url)
