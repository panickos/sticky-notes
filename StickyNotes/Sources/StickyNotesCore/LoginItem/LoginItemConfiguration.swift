/// Login item (start at login) configuration (Spec 05 extension).
public struct LoginItemConfiguration: Equatable, Sendable {
    public static let v1 = LoginItemConfiguration(
        preferenceKey: "startAtLoginEnabled",
        enablesOnFirstLaunch: true
    )

    public let preferenceKey: String
    public let enablesOnFirstLaunch: Bool

    public init(preferenceKey: String, enablesOnFirstLaunch: Bool) {
        self.preferenceKey = preferenceKey
        self.enablesOnFirstLaunch = enablesOnFirstLaunch
    }
}

/// Resolves whether the login item should be registered from stored preference.
public enum LoginItemPreferenceResolver: Equatable, Sendable {
    public static func shouldEnable(
        storedPreference: Bool?,
        configuration: LoginItemConfiguration = .v1
    ) -> Bool {
        storedPreference ?? configuration.enablesOnFirstLaunch
    }
}
