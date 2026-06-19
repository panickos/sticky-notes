/// Spec 08 manual acceptance scenarios for AeroSpace compatibility.
public enum AerospaceCompatibilityScenario: String, CaseIterable, Sendable {
    case tiledAppFocus
    case workspaceSwitch
    case layoutToggleOnOtherApp
    case noteCreateDragResize
    case globalShowHideHotkey
    case multiMonitor
}

/// Configuration flags that automated tests can verify before manual AeroSpace runs.
public enum AerospaceConfigurationPrerequisite: String, CaseIterable, Sendable {
    case elevatedWindowLevel
    case joinsAllSpaces
    case stationaryAcrossWorkspaces
    case ignoresWindowCycle
    case fullScreenAuxiliary
    case floatingNonActivatingPanel
    case doesNotHideOnDeactivate
}

public enum AerospaceVerificationKind: String, Sendable {
    case manualAcceptance
    case automatedPrerequisite
}

/// One row in the Spec 08 manual test matrix.
public struct AerospaceCompatibilityCase: Equatable, Sendable {
    public let scenario: AerospaceCompatibilityScenario
    public let userAction: String
    public let expectedBehavior: String
    public let verificationKind: AerospaceVerificationKind
    public let configurationPrerequisites: [AerospaceConfigurationPrerequisite]

    public init(
        scenario: AerospaceCompatibilityScenario,
        userAction: String,
        expectedBehavior: String,
        verificationKind: AerospaceVerificationKind,
        configurationPrerequisites: [AerospaceConfigurationPrerequisite]
    ) {
        self.scenario = scenario
        self.userAction = userAction
        self.expectedBehavior = expectedBehavior
        self.verificationKind = verificationKind
        self.configurationPrerequisites = configurationPrerequisites
    }
}

/// Catalog of Spec 08 acceptance scenarios with expected behavior and prerequisite mapping.
public struct AerospaceCompatibilityMatrix: Equatable, Sendable {
    public let cases: [AerospaceCompatibilityCase]

    public init(cases: [AerospaceCompatibilityCase]) {
        self.cases = cases
    }

    public var manualCases: [AerospaceCompatibilityCase] {
        cases.filter { $0.verificationKind == .manualAcceptance }
    }

    public var automatedPrerequisiteCases: [AerospaceCompatibilityCase] {
        cases.filter { $0.verificationKind == .automatedPrerequisite }
    }

    public static let v1 = AerospaceCompatibilityMatrix(cases: [
        AerospaceCompatibilityCase(
            scenario: .tiledAppFocus,
            userAction: "Focus a tiled app window (Chrome, Terminal)",
            expectedBehavior: "Notes stay visible above the tiled window",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.elevatedWindowLevel, .ignoresWindowCycle]
        ),
        AerospaceCompatibilityCase(
            scenario: .workspaceSwitch,
            userAction: "Switch AeroSpace workspace",
            expectedBehavior: "Notes remain visible on the new workspace, in place, still on top",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [
                .joinsAllSpaces,
                .stationaryAcrossWorkspaces,
                .fullScreenAuxiliary,
            ]
        ),
        AerospaceCompatibilityCase(
            scenario: .layoutToggleOnOtherApp,
            userAction: "Toggle tiling ↔ floating on another app",
            expectedBehavior: "Notes unaffected; still on top",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.elevatedWindowLevel, .floatingNonActivatingPanel]
        ),
        AerospaceCompatibilityCase(
            scenario: .noteCreateDragResize,
            userAction: "Create, drag, or resize a note",
            expectedBehavior: "AeroSpace does not snap or retile the note",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.floatingNonActivatingPanel]
        ),
        AerospaceCompatibilityCase(
            scenario: .globalShowHideHotkey,
            userAction: "Press ⌃⌥N from any workspace",
            expectedBehavior: "All notes hide; press again to restore",
            verificationKind: .manualAcceptance,
            configurationPrerequisites: []
        ),
        AerospaceCompatibilityCase(
            scenario: .multiMonitor,
            userAction: "Place notes on multiple displays (if available)",
            expectedBehavior: "Notes stay on the correct screen and remain on top",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.joinsAllSpaces, .elevatedWindowLevel]
        ),
    ])
}
