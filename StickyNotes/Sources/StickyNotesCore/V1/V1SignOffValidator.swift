import AppKit

public struct V1PrerequisiteValidation: Equatable, Sendable {
    public let prerequisite: V1ConfigurationPrerequisite
    public let passes: Bool
    public let detail: String

    public init(prerequisite: V1ConfigurationPrerequisite, passes: Bool, detail: String) {
        self.prerequisite = prerequisite
        self.passes = passes
        self.detail = detail
    }
}

/// Validates v1 configuration against Spec 07 automated prerequisites.
public enum V1SignOffValidator {
    public static func validate(
        panelConfiguration: NotePanelConfiguration = .aerospaceCompatible,
        hotkeyBindings: StickyNoteHotkeyBindings = .v1Defaults
    ) -> [V1PrerequisiteValidation] {
        V1ConfigurationPrerequisite.allCases.map { prerequisite in
            let passes = check(
                prerequisite,
                panelConfiguration: panelConfiguration,
                hotkeyBindings: hotkeyBindings
            )
            return V1PrerequisiteValidation(
                prerequisite: prerequisite,
                passes: passes,
                detail: detail(for: prerequisite, passes: passes)
            )
        }
    }

    public static func allAutomatedPrerequisitesPass(
        panelConfiguration: NotePanelConfiguration = .aerospaceCompatible,
        hotkeyBindings: StickyNoteHotkeyBindings = .v1Defaults
    ) -> Bool {
        validate(
            panelConfiguration: panelConfiguration,
            hotkeyBindings: hotkeyBindings
        ).allSatisfy(\.passes)
    }

    /// True when every automated Spec 07 criterion has passing prerequisites.
    public static func automatedSignOffGatePasses(
        panelConfiguration: NotePanelConfiguration = .aerospaceCompatible,
        hotkeyBindings: StickyNoteHotkeyBindings = .v1Defaults
    ) -> Bool {
        let validations = validate(
            panelConfiguration: panelConfiguration,
            hotkeyBindings: hotkeyBindings
        )
        let passing = Set(validations.filter(\.passes).map(\.prerequisite))

        return V1DefinitionOfDone.v1.automatedPrerequisiteCases.allSatisfy { caseItem in
            caseItem.configurationPrerequisites.allSatisfy { passing.contains($0) }
        }
    }

    private static func check(
        _ prerequisite: V1ConfigurationPrerequisite,
        panelConfiguration: NotePanelConfiguration,
        hotkeyBindings: StickyNoteHotkeyBindings
    ) -> Bool {
        switch prerequisite {
        case .alwaysOnTopPanel:
            return panelConfiguration.level.rawValue >= NSWindow.Level.statusBar.rawValue
        case .draggableResizablePanel:
            return panelConfiguration.isFloatingPanel
                && panelConfiguration.styleMask.contains(.resizable)
        case .allV1NoteActions:
            return Set(NoteAction.allCases) == Set(NoteAction.v1PerNoteActions + NoteAction.v1GlobalActions)
        case .presetColorPalette:
            return !NoteAppearanceDefaults.colorPalette.isEmpty
                && NoteAppearanceDefaults.colorPalette.contains(NoteAppearanceDefaults.defaultColor)
        case .hoverChromeControls:
            return Set(NoteChromeConfiguration.v1.hoverControls) == Set(NoteHoverControl.allCases)
        case .markdownFeatureSet:
            return StickyNoteMarkdownFeatures.required == Set(StickyNoteMarkdownFeature.allCases)
        case .headerDragHandle:
            return NoteInteractionConfiguration.v1.dragHandle.region == .noteHeader
                && NoteInteractionConfiguration.v1.isDraggable(.noteHeader)
        case .localJSONPersistence:
            return NotePersistenceConfiguration.v1.autosaveDebounceInterval > 0
                && NotePersistenceConfiguration.v1.fileName.hasSuffix(".json")
        case .sessionSnapshotSchema:
            return NoteSessionSnapshot.empty.schemaVersion >= 1
        case .menuBarShellConfiguration:
            return AppShellConfiguration.v1.activationPolicy == .accessory
                && Set(AppShellConfiguration.v1.requiredMenuActions)
                    == Set([MenuBarAction.showHideNotes, .newNote, .startAtLogin, .quit])
        case .distributionNoDockBundle:
            return DistributionConfiguration.v1.isUIElement
                && DistributionConfiguration.v1.bundleIdentifier == "dev.stickynotes.app"
                && !DistributionConfiguration.v1.iconFileName.isEmpty
        case .globalHotkeyBindings:
            guard StickyNoteHotkeyBindings.requiredActions.isSubset(of: hotkeyBindings.boundActions),
                  let toggle = hotkeyBindings.binding(for: .toggleVisibility),
                  let create = hotkeyBindings.binding(for: .createNewNote)
            else {
                return false
            }
            return toggle.modifiers.contains(.control) && create.modifiers.contains(.control)
        case .aerospacePrerequisitesMet:
            return AerospaceConfigurationValidator.allPrerequisitesPass(
                configuration: panelConfiguration
            )
        }
    }

    private static func detail(
        for prerequisite: V1ConfigurationPrerequisite,
        passes: Bool
    ) -> String {
        if passes {
            return "Prerequisite satisfied: \(prerequisite.rawValue)"
        }
        return "Prerequisite failed: \(prerequisite.rawValue)"
    }
}
