import AppKit
import Testing
@testable import StickyNotesCore

@Suite("AerospaceCompatibilityMatrix — Spec 08 manual test catalog")
struct AerospaceCompatibilityMatrixTests {
    @Test("v1 matrix covers all six Spec 08 scenarios")
    func coversAllScenarios() {
        let matrix = AerospaceCompatibilityMatrix.v1
        let scenarios = Set(matrix.cases.map(\.scenario))
        #expect(scenarios == Set(AerospaceCompatibilityScenario.allCases))
    }

    @Test("every matrix case documents user action and expected behavior")
    func casesAreDocumented() {
        for caseItem in AerospaceCompatibilityMatrix.v1.cases {
            #expect(!caseItem.userAction.isEmpty)
            #expect(!caseItem.expectedBehavior.isEmpty)
        }
    }

    @Test("matrix separates manual acceptance from automated prerequisites")
    func verificationKinds() {
        let matrix = AerospaceCompatibilityMatrix.v1
        #expect(matrix.manualCases.count == 1)
        #expect(matrix.automatedPrerequisiteCases.count == 5)
    }

    @Test("global show/hide hotkey has no panel configuration prerequisites")
    func hotkeyCaseHasNoPanelPrerequisites() {
        let hotkeyCase = AerospaceCompatibilityMatrix.v1.cases.first {
            $0.scenario == .globalShowHideHotkey
        }
        #expect(hotkeyCase?.configurationPrerequisites.isEmpty == true)
    }
}

@Suite("AerospaceConfigurationValidator — automated prerequisites")
struct AerospaceConfigurationValidatorTests {
    @Test("aerospaceCompatible passes all configuration prerequisites")
    func aerospaceCompatiblePasses() {
        let validations = AerospaceConfigurationValidator.validate(
            configuration: .aerospaceCompatible
        )
        for validation in validations {
            #expect(validation.passes)
        }
        #expect(AerospaceConfigurationValidator.allPrerequisitesPass(
            configuration: .aerospaceCompatible
        ))
    }

    @Test("floating level alone fails elevated window level prerequisite")
    func floatingLevelFails() {
        let config = NotePanelConfiguration(
            level: .floating,
            collectionBehavior: NotePanelConfiguration.aerospaceCompatible.collectionBehavior,
            styleMask: NotePanelConfiguration.aerospaceCompatible.styleMask,
            isFloatingPanel: true,
            becomesKeyOnlyIfNeeded: true,
            hidesOnDeactivate: false
        )
        let validations = AerospaceConfigurationValidator.validate(configuration: config)
        let levelCheck = validations.first { $0.prerequisite == .elevatedWindowLevel }
        #expect(levelCheck?.passes == false)
    }

    @Test("missing canJoinAllSpaces fails workspace prerequisite")
    func missingJoinAllSpacesFails() {
        let behavior = NotePanelConfiguration.aerospaceCompatible.collectionBehavior
        let withoutAllSpaces = behavior.subtracting(.canJoinAllSpaces)
        let config = NotePanelConfiguration(
            level: .statusBar,
            collectionBehavior: withoutAllSpaces,
            styleMask: NotePanelConfiguration.aerospaceCompatible.styleMask,
            isFloatingPanel: true,
            becomesKeyOnlyIfNeeded: true,
            hidesOnDeactivate: false
        )
        let validations = AerospaceConfigurationValidator.validate(configuration: config)
        let joinSpaces = validations.first { $0.prerequisite == .joinsAllSpaces }
        #expect(joinSpaces?.passes == false)
    }

    @Test("each matrix case prerequisites pass for aerospaceCompatible")
    func matrixCasePrerequisitesPass() {
        let validations = AerospaceConfigurationValidator.validate(
            configuration: .aerospaceCompatible
        )
        let passing = Set(validations.filter(\.passes).map(\.prerequisite))

        for caseItem in AerospaceCompatibilityMatrix.v1.cases {
            for prerequisite in caseItem.configurationPrerequisites {
                #expect(passing.contains(prerequisite))
            }
        }
    }
}

@Suite("AerospaceConfigurationValidator — factory prerequisites")
@MainActor
struct AerospaceFactoryValidatorTests {
    @Test("factory panel passes hidesOnDeactivate prerequisite")
    func hidesOnDeactivate() {
        let panel = NotePanelFactory.makePanel(
            configuration: .aerospaceCompatible,
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 150)
        )
        #expect(panel.hidesOnDeactivate == false)
        #expect(AerospaceConfigurationValidator.factoryPrerequisitesPass(panel: panel))
    }

    @Test("factory panel passes all prerequisites for aerospaceCompatible")
    func factoryPassesAll() {
        let panel = NotePanelFactory.makePanel(
            configuration: .aerospaceCompatible,
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 150)
        )
        #expect(AerospaceConfigurationValidator.allPrerequisitesPass(
            configuration: .aerospaceCompatible,
            panel: panel
        ))
    }
}
