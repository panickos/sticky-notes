import Foundation
import ServiceManagement
import StickyNotesCore

@MainActor
protocol LoginItemRegistering: AnyObject {
    var isRegistered: Bool { get }
    func setRegistered(_ enabled: Bool) throws
}

@MainActor
final class SMAppServiceLoginItemRegistrar: LoginItemRegistering {
    var isRegistered: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setRegistered(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}

@MainActor
final class LoginItemController {
    private let configuration: LoginItemConfiguration
    private let registrar: LoginItemRegistering
    private let defaults: UserDefaults

    init(
        configuration: LoginItemConfiguration = .v1,
        registrar: LoginItemRegistering = SMAppServiceLoginItemRegistrar(),
        defaults: UserDefaults = .standard
    ) {
        self.configuration = configuration
        self.registrar = registrar
        self.defaults = defaults
    }

    var isEnabled: Bool {
        if defaults.object(forKey: configuration.preferenceKey) == nil {
            return registrar.isRegistered
        }
        return defaults.bool(forKey: configuration.preferenceKey)
    }

    func applyOnLaunch() {
        let shouldEnable = LoginItemPreferenceResolver.shouldEnable(
            storedPreference: storedPreference
        )
        syncRegistration(enabled: shouldEnable, persistPreference: storedPreference == nil)
    }

    func toggle() {
        syncRegistration(enabled: !isEnabled, persistPreference: true)
    }

    private var storedPreference: Bool? {
        guard defaults.object(forKey: configuration.preferenceKey) != nil else {
            return nil
        }
        return defaults.bool(forKey: configuration.preferenceKey)
    }

    private func syncRegistration(enabled: Bool, persistPreference: Bool) {
        do {
            try registrar.setRegistered(enabled)
            if persistPreference {
                defaults.set(enabled, forKey: configuration.preferenceKey)
            }
        } catch {
            NSLog("StickyNotes: login item registration failed: \(error)")
        }
    }
}
