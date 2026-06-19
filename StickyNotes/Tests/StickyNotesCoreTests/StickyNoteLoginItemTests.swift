import Foundation
import Testing
@testable import StickyNotesCore

@Suite("LoginItemConfiguration — start at login")
struct LoginItemConfigurationTests {
    @Test("v1 enables login item on first launch by default")
    func enablesOnFirstLaunch() {
        #expect(LoginItemConfiguration.v1.enablesOnFirstLaunch == true)
    }

    @Test("v1 preference key is stable")
    func preferenceKey() {
        #expect(LoginItemConfiguration.v1.preferenceKey == "startAtLoginEnabled")
    }
}

@Suite("LoginItemPreferenceResolver — stored preference")
struct LoginItemPreferenceResolverTests {
    @Test("nil preference uses configuration default")
    func nilUsesDefault() {
        #expect(LoginItemPreferenceResolver.shouldEnable(storedPreference: nil) == true)
    }

    @Test("stored true enables login item")
    func storedTrue() {
        #expect(LoginItemPreferenceResolver.shouldEnable(storedPreference: true) == true)
    }

    @Test("stored false disables login item")
    func storedFalse() {
        #expect(LoginItemPreferenceResolver.shouldEnable(storedPreference: false) == false)
    }

    @Test("respects custom configuration default")
    func customDefault() {
        let config = LoginItemConfiguration(
            preferenceKey: "test",
            enablesOnFirstLaunch: false
        )
        #expect(LoginItemPreferenceResolver.shouldEnable(storedPreference: nil, configuration: config) == false)
    }
}
