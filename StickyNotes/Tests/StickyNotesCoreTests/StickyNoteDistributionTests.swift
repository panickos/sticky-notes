import Foundation
import Testing
@testable import StickyNotesCore

@Suite("DistributionConfiguration — v1 app bundle identity")
struct DistributionConfigurationTests {
    @Test("v1 bundle identifier is stable for AeroSpace on-window-detected")
    func bundleIdentifier() {
        #expect(DistributionConfiguration.v1.bundleIdentifier == "dev.stickynotes.app")
    }

    @Test("v1 marks app as LSUIElement menu bar accessory")
    func lsuiElement() {
        #expect(DistributionConfiguration.v1.isUIElement == true)
    }

    @Test("v1 executable name matches SPM product")
    func bundleExecutable() {
        #expect(DistributionConfiguration.v1.bundleExecutable == "StickyNotes")
    }

    @Test("v1 minimum macOS version matches Package.swift platform")
    func minimumSystemVersion() {
        #expect(DistributionConfiguration.v1.minimumSystemVersion == "14.0")
    }

    @Test("v1 icon file name matches bundled AppIcon.icns")
    func iconFileName() {
        #expect(DistributionConfiguration.v1.iconFileName == "AppIcon")
    }

    @Test("AeroSpace snippet references bundle identifier")
    func aerospaceSnippet() {
        let snippet = DistributionConfiguration.v1.aerospaceOnWindowDetectedSnippet
        #expect(snippet.contains("dev.stickynotes.app"))
        #expect(snippet.contains("layout floating"))
    }
}

@Suite("InfoPlistGenerator — distribution Info.plist")
struct InfoPlistGeneratorTests {
    @Test("generates required keys for a signed .app bundle")
    func requiredKeys() throws {
        let plist = InfoPlistGenerator.dictionary(for: .v1)

        #expect(plist["CFBundleIdentifier"] as? String == "dev.stickynotes.app")
        #expect(plist["CFBundleExecutable"] as? String == "StickyNotes")
        #expect(plist["CFBundleName"] as? String == "StickyNotes")
        #expect(plist["CFBundlePackageType"] as? String == "APPL")
        #expect(plist["LSUIElement"] as? Bool == true)
        #expect(plist["LSMinimumSystemVersion"] as? String == "14.0")
        #expect(plist["CFBundleIconFile"] as? String == "AppIcon")
    }

    @Test("writes valid XML plist to disk")
    func writePlist() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let url = directory.appendingPathComponent("Info.plist")
        try InfoPlistGenerator.writePlist(for: .v1, to: url)

        let data = try Data(contentsOf: url)
        let parsed = try PropertyListSerialization.propertyList(from: data, format: nil)
        let dict = try #require(parsed as? [String: Any])
        #expect(dict["LSUIElement"] as? Bool == true)
    }
}

@Suite("AppBundleLayout — .app directory structure")
struct AppBundleLayoutTests {
    @Test("macOS app bundle path uses .app suffix")
    func appBundleURL() {
        let base = URL(fileURLWithPath: "/tmp/dist", isDirectory: true)
        let url = AppBundleLayout.macOSAppBundleURL(baseDirectory: base, appName: "StickyNotes")
        #expect(url.lastPathComponent == "StickyNotes.app")
    }

    @Test("executable lives under Contents/MacOS")
    func executableURL() {
        let bundle = URL(fileURLWithPath: "/tmp/dist/StickyNotes.app", isDirectory: true)
        let executable = AppBundleLayout.executableURL(
            appBundleURL: bundle,
            executableName: "StickyNotes"
        )
        #expect(executable.path.hasSuffix("StickyNotes.app/Contents/MacOS/StickyNotes"))
    }

    @Test("Info.plist lives under Contents")
    func infoPlistURL() {
        let bundle = URL(fileURLWithPath: "/tmp/dist/StickyNotes.app", isDirectory: true)
        let plist = AppBundleLayout.infoPlistURL(appBundleURL: bundle)
        #expect(plist.path.hasSuffix("StickyNotes.app/Contents/Info.plist"))
    }

    @Test("app icon lives under Contents/Resources")
    func appIconURL() {
        let bundle = URL(fileURLWithPath: "/tmp/dist/StickyNotes.app", isDirectory: true)
        let icon = AppBundleLayout.appIconURL(appBundleURL: bundle, iconFileName: "AppIcon")
        #expect(icon.path.hasSuffix("StickyNotes.app/Contents/Resources/AppIcon.icns"))
    }
}
