import AppKit

public struct AerospacePrerequisiteValidation: Equatable, Sendable {
    public let prerequisite: AerospaceConfigurationPrerequisite
    public let passes: Bool
    public let detail: String

    public init(prerequisite: AerospaceConfigurationPrerequisite, passes: Bool, detail: String) {
        self.prerequisite = prerequisite
        self.passes = passes
        self.detail = detail
    }
}

/// Validates panel configuration and factory output against Spec 08 automated prerequisites.
public enum AerospaceConfigurationValidator {
    public static func validate(
        configuration: NotePanelConfiguration
    ) -> [AerospacePrerequisiteValidation] {
        AerospaceConfigurationPrerequisite.allCases.map { prerequisite in
            let passes = check(prerequisite, configuration: configuration)
            return AerospacePrerequisiteValidation(
                prerequisite: prerequisite,
                passes: passes,
                detail: detail(for: prerequisite, passes: passes)
            )
        }
    }

    @MainActor
    public static func validateFactory(panel: NSPanel) -> [AerospacePrerequisiteValidation] {
        let passes = !panel.hidesOnDeactivate
        return [
            AerospacePrerequisiteValidation(
                prerequisite: .doesNotHideOnDeactivate,
                passes: passes,
                detail: passes
                    ? "Panel does not hide when app deactivates"
                    : "Panel hides on deactivate — notes may vanish during workspace switches"
            ),
        ]
    }

    public static func allPrerequisitesPass(configuration: NotePanelConfiguration) -> Bool {
        validate(configuration: configuration).allSatisfy(\.passes)
    }

    @MainActor
    public static func factoryPrerequisitesPass(panel: NSPanel) -> Bool {
        validateFactory(panel: panel).allSatisfy(\.passes)
    }

    @MainActor
    public static func allPrerequisitesPass(
        configuration: NotePanelConfiguration,
        panel: NSPanel
    ) -> Bool {
        allPrerequisitesPass(configuration: configuration)
            && factoryPrerequisitesPass(panel: panel)
    }

    private static func check(
        _ prerequisite: AerospaceConfigurationPrerequisite,
        configuration: NotePanelConfiguration
    ) -> Bool {
        switch prerequisite {
        case .elevatedWindowLevel:
            configuration.level.rawValue >= NSWindow.Level.statusBar.rawValue
        case .joinsAllSpaces:
            configuration.collectionBehavior.contains(.canJoinAllSpaces)
        case .stationaryAcrossWorkspaces:
            configuration.collectionBehavior.contains(.stationary)
        case .ignoresWindowCycle:
            configuration.collectionBehavior.contains(.ignoresCycle)
        case .fullScreenAuxiliary:
            configuration.collectionBehavior.contains(.fullScreenAuxiliary)
        case .floatingNonActivatingPanel:
            configuration.isFloatingPanel
                && configuration.styleMask.contains(.nonactivatingPanel)
        case .doesNotHideOnDeactivate:
            !configuration.hidesOnDeactivate
        }
    }

    private static func detail(
        for prerequisite: AerospaceConfigurationPrerequisite,
        passes: Bool
    ) -> String {
        if passes {
            return "Prerequisite satisfied: \(prerequisite.rawValue)"
        }
        return "Prerequisite failed: \(prerequisite.rawValue)"
    }
}
