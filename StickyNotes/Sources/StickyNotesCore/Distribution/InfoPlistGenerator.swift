import Foundation

/// Builds the Info.plist dictionary for a macOS `.app` bundle.
public enum InfoPlistGenerator {
    public static func dictionary(for configuration: DistributionConfiguration) -> [String: Any] {
        [
            "CFBundleDevelopmentRegion": "en",
            "CFBundleExecutable": configuration.bundleExecutable,
            "CFBundleIdentifier": configuration.bundleIdentifier,
            "CFBundleInfoDictionaryVersion": "6.0",
            "CFBundleName": configuration.bundleName,
            "CFBundleDisplayName": configuration.bundleDisplayName,
            "CFBundlePackageType": "APPL",
            "CFBundleShortVersionString": configuration.bundleShortVersion,
            "CFBundleVersion": configuration.bundleVersion,
            "LSMinimumSystemVersion": configuration.minimumSystemVersion,
            "LSUIElement": configuration.isUIElement,
            "NSHighResolutionCapable": true,
            "CFBundleIconFile": configuration.iconFileName,
        ]
    }

    public static func writePlist(for configuration: DistributionConfiguration, to url: URL) throws {
        let data = try PropertyListSerialization.data(
            fromPropertyList: dictionary(for: configuration),
            format: .xml,
            options: 0
        )
        try data.write(to: url, options: .atomic)
    }
}
