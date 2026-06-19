import Foundation

/// Standard macOS `.app` bundle directory layout.
public enum AppBundleLayout {
    public static func macOSAppBundleURL(baseDirectory: URL, appName: String) -> URL {
        baseDirectory.appendingPathComponent("\(appName).app", isDirectory: true)
    }

    public static func contentsURL(appBundleURL: URL) -> URL {
        appBundleURL.appendingPathComponent("Contents", isDirectory: true)
    }

    public static func macOSDirectoryURL(appBundleURL: URL) -> URL {
        contentsURL(appBundleURL: appBundleURL).appendingPathComponent("MacOS", isDirectory: true)
    }

    public static func executableURL(appBundleURL: URL, executableName: String) -> URL {
        macOSDirectoryURL(appBundleURL: appBundleURL).appendingPathComponent(executableName)
    }

    public static func infoPlistURL(appBundleURL: URL) -> URL {
        contentsURL(appBundleURL: appBundleURL).appendingPathComponent("Info.plist")
    }

    public static func resourcesURL(appBundleURL: URL) -> URL {
        contentsURL(appBundleURL: appBundleURL).appendingPathComponent("Resources", isDirectory: true)
    }

    public static func appIconURL(appBundleURL: URL, iconFileName: String) -> URL {
        resourcesURL(appBundleURL: appBundleURL).appendingPathComponent("\(iconFileName).icns")
    }
}
