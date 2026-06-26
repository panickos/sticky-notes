import AppKit
import Testing
@testable import StickyNotesCore

@Suite("V1DefinitionOfDone — Spec 07 sign-off catalog")
struct V1DefinitionOfDoneTests {
    @Test("v1 catalog covers all six Spec 07 criteria")
    func coversAllCriteria() {
        let definition = V1DefinitionOfDone.v1
        let criteria = Set(definition.cases.map(\.criterion))
        #expect(criteria == Set(V1SignOffCriterion.allCases))
    }

    @Test("every sign-off case documents user action and expected behavior")
    func casesAreDocumented() {
        for caseItem in V1DefinitionOfDone.v1.cases {
            #expect(!caseItem.userAction.isEmpty)
            #expect(!caseItem.expectedBehavior.isEmpty)
        }
    }

    @Test("catalog separates manual acceptance from automated prerequisites")
    func verificationKinds() {
        let definition = V1DefinitionOfDone.v1
        #expect(definition.manualCases.count == 2)
        #expect(definition.automatedPrerequisiteCases.count == 4)
    }

    @Test("daily use polish and aerospace matrix are manual acceptance")
    func manualCriteria() {
        let manual = Set(V1DefinitionOfDone.v1.manualCases.map(\.criterion))
        #expect(manual == [.dailyUsePolish, .aerospaceMatrixPasses])
    }
}

@Suite("V1SignOffValidator — automated prerequisites")
struct V1SignOffValidatorTests {
    @Test("all automated configuration prerequisites pass for v1")
    func allPrerequisitesPass() {
        #expect(V1SignOffValidator.allAutomatedPrerequisitesPass())
    }

    @Test("menu bar accessory requires accessory policy and LSUIElement bundle")
    func menuBarAccessory() {
        let validations = V1SignOffValidator.validate()
        let shell = validations.first { $0.prerequisite == .menuBarShellConfiguration }
        let bundle = validations.first { $0.prerequisite == .distributionNoDockBundle }
        #expect(shell?.passes == true)
        #expect(bundle?.passes == true)
    }

    @Test("persistence prerequisites cover local JSON and session snapshot")
    func persistence() {
        let validations = V1SignOffValidator.validate()
        let json = validations.first { $0.prerequisite == .localJSONPersistence }
        let snapshot = validations.first { $0.prerequisite == .sessionSnapshotSchema }
        #expect(json?.passes == true)
        #expect(snapshot?.passes == true)
    }

    @Test("global hotkeys cover toggle visibility and create new note")
    func globalHotkeys() {
        let validations = V1SignOffValidator.validate()
        let hotkeys = validations.first { $0.prerequisite == .globalHotkeyBindings }
        #expect(hotkeys?.passes == true)
    }

    @Test("specs 01–06 prerequisite checks pass for v1 configuration")
    func specs01Through06() {
        let definition = V1DefinitionOfDone.v1
        let specsCase = definition.cases.first { $0.criterion == .specs01Through06Met }
        let validations = V1SignOffValidator.validate()
        let passing = Set(validations.filter(\.passes).map(\.prerequisite))

        for prerequisite in specsCase?.configurationPrerequisites ?? [] {
            #expect(passing.contains(prerequisite))
        }
    }

    @Test("aerospace prerequisites delegate to AerospaceConfigurationValidator")
    func aerospacePrerequisites() {
        #expect(
            AerospaceConfigurationValidator.allPrerequisitesPass(
                configuration: .aerospaceCompatible
            )
        )
        let validations = V1SignOffValidator.validate()
        let aerospace = validations.first { $0.prerequisite == .aerospacePrerequisitesMet }
        #expect(aerospace?.passes == true)
    }

    @Test("note snap prerequisites delegate to NoteSnapGateValidator")
    func noteSnapPrerequisites() {
        #expect(NoteSnapGateValidator.allPrerequisitesPass())
        let validations = V1SignOffValidator.validate()
        let snap = validations.first { $0.prerequisite == .noteSnapPrerequisitesMet }
        #expect(snap?.passes == true)
    }

    @Test("floating-only panel level fails always-on-top prerequisite")
    func floatingLevelFailsAlwaysOnTop() {
        let config = NotePanelConfiguration(
            level: .floating,
            collectionBehavior: NotePanelConfiguration.aerospaceCompatible.collectionBehavior,
            styleMask: NotePanelConfiguration.aerospaceCompatible.styleMask,
            isFloatingPanel: true,
            becomesKeyOnlyIfNeeded: true,
            hidesOnDeactivate: false
        )
        let validations = V1SignOffValidator.validate(panelConfiguration: config)
        let alwaysOnTop = validations.first { $0.prerequisite == .alwaysOnTopPanel }
        #expect(alwaysOnTop?.passes == false)
    }

    @Test("missing required hotkey action fails global hotkey prerequisite")
    func missingHotkeyFails() {
        let incomplete = StickyNoteHotkeyBindings(chords: [
            .toggleVisibility: HotkeyChord(key: "n", modifiers: [.control, .option]),
        ])
        let validations = V1SignOffValidator.validate(hotkeyBindings: incomplete)
        let hotkeys = validations.first { $0.prerequisite == .globalHotkeyBindings }
        #expect(hotkeys?.passes == false)
    }
}

@Suite("V1SignOffValidator — definition-of-done gate")
struct V1SignOffGateTests {
    @Test("automated sign-off gate passes for v1 configuration")
    func automatedGatePasses() {
        #expect(V1SignOffValidator.automatedSignOffGatePasses())
    }

    @Test("each automated definition case prerequisites pass")
    func automatedCasesPass() {
        let validations = V1SignOffValidator.validate()
        let passing = Set(validations.filter(\.passes).map(\.prerequisite))

        for caseItem in V1DefinitionOfDone.v1.automatedPrerequisiteCases {
            for prerequisite in caseItem.configurationPrerequisites {
                #expect(passing.contains(prerequisite))
            }
        }
    }

    @Test("automated sign-off gate fails for floating-only panel level")
    func gateFailsOnBadConfig() {
        let config = NotePanelConfiguration(
            level: .floating,
            collectionBehavior: NotePanelConfiguration.aerospaceCompatible.collectionBehavior,
            styleMask: NotePanelConfiguration.aerospaceCompatible.styleMask,
            isFloatingPanel: true,
            becomesKeyOnlyIfNeeded: true,
            hidesOnDeactivate: false
        )
        #expect(V1SignOffValidator.automatedSignOffGatePasses(panelConfiguration: config) == false)
    }
}
