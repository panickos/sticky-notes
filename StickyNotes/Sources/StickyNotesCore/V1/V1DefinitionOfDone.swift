/// Spec 07 definition-of-done criteria for v1 sign-off.
public enum V1SignOffCriterion: String, CaseIterable, Sendable {
    case specs01Through06Met
    case menuBarAccessoryNoDock
    case persistenceAcrossRelaunch
    case globalHotkeysFromAnyApp
    case dailyUsePolish
    case aerospaceMatrixPasses
}

/// Configuration flags that automated tests can verify before manual sign-off runs.
public enum V1ConfigurationPrerequisite: String, CaseIterable, Sendable {
    case alwaysOnTopPanel
    case draggableResizablePanel
    case allV1NoteActions
    case presetColorPalette
    case hoverChromeControls
    case markdownFeatureSet
    case headerDragHandle
    case localJSONPersistence
    case sessionSnapshotSchema
    case menuBarShellConfiguration
    case distributionNoDockBundle
    case globalHotkeyBindings
    case aerospacePrerequisitesMet
}

public enum V1VerificationKind: String, Sendable {
    case automatedPrerequisite
    case manualAcceptance
}

/// One row in the Spec 07 sign-off checklist.
public struct V1SignOffCase: Equatable, Sendable {
    public let criterion: V1SignOffCriterion
    public let userAction: String
    public let expectedBehavior: String
    public let verificationKind: V1VerificationKind
    public let configurationPrerequisites: [V1ConfigurationPrerequisite]

    public init(
        criterion: V1SignOffCriterion,
        userAction: String,
        expectedBehavior: String,
        verificationKind: V1VerificationKind,
        configurationPrerequisites: [V1ConfigurationPrerequisite]
    ) {
        self.criterion = criterion
        self.userAction = userAction
        self.expectedBehavior = expectedBehavior
        self.verificationKind = verificationKind
        self.configurationPrerequisites = configurationPrerequisites
    }
}

/// Catalog of Spec 07 acceptance criteria with expected behavior and prerequisite mapping.
public struct V1DefinitionOfDone: Equatable, Sendable {
    public let cases: [V1SignOffCase]

    public init(cases: [V1SignOffCase]) {
        self.cases = cases
    }

    public var manualCases: [V1SignOffCase] {
        cases.filter { $0.verificationKind == .manualAcceptance }
    }

    public var automatedPrerequisiteCases: [V1SignOffCase] {
        cases.filter { $0.verificationKind == .automatedPrerequisite }
    }

    public static let v1 = V1DefinitionOfDone(cases: [
        V1SignOffCase(
            criterion: .specs01Through06Met,
            userAction: "Run automated v1 prerequisite suite",
            expectedBehavior: "Overlay, note model, persistence, menu bar, hotkeys, and native stack configs satisfy Specs 01–06",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [
                .alwaysOnTopPanel,
                .draggableResizablePanel,
                .allV1NoteActions,
                .presetColorPalette,
                .hoverChromeControls,
                .markdownFeatureSet,
                .headerDragHandle,
                .localJSONPersistence,
                .sessionSnapshotSchema,
                .menuBarShellConfiguration,
                .globalHotkeyBindings,
                .aerospacePrerequisitesMet,
            ]
        ),
        V1SignOffCase(
            criterion: .menuBarAccessoryNoDock,
            userAction: "Launch packaged StickyNotes.app",
            expectedBehavior: "No dock icon; menu bar icon is the primary entry point",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [
                .menuBarShellConfiguration,
                .distributionNoDockBundle,
            ]
        ),
        V1SignOffCase(
            criterion: .persistenceAcrossRelaunch,
            userAction: "Edit note content and move a note, wait for autosave, quit, relaunch",
            expectedBehavior: "Content, positions, colors, and z-order restore; hidden state is not persisted",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [
                .localJSONPersistence,
                .sessionSnapshotSchema,
            ]
        ),
        V1SignOffCase(
            criterion: .globalHotkeysFromAnyApp,
            userAction: "Press ⌃⌥N and ⌃⌥⇧N while another app is focused",
            expectedBehavior: "Toggle show/hide all notes and create a new note without Accessibility permission",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.globalHotkeyBindings]
        ),
        V1SignOffCase(
            criterion: .dailyUsePolish,
            userAction: "Use Sticky Notes for a full workday",
            expectedBehavior: "UX feels polished enough for daily personal use",
            verificationKind: .manualAcceptance,
            configurationPrerequisites: []
        ),
        V1SignOffCase(
            criterion: .aerospaceMatrixPasses,
            userAction: "Run Spec 08 manual AeroSpace test matrix",
            expectedBehavior: "All six AeroSpace scenarios pass with notes on top",
            verificationKind: .manualAcceptance,
            configurationPrerequisites: [.aerospacePrerequisitesMet]
        ),
    ])
}
