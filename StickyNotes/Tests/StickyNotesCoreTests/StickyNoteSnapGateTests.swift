import CoreGraphics
import Foundation
import Testing
@testable import StickyNotesCore

@Suite("NoteSnapAcceptanceMatrix — Spec 09 acceptance catalog")
struct NoteSnapAcceptanceMatrixTests {
    @Test("v1 matrix covers all twelve Spec 09 scenarios")
    func coversAllScenarios() {
        let matrix = NoteSnapAcceptanceMatrix.v1
        let scenarios = Set(matrix.cases.map(\.scenario))
        #expect(scenarios == Set(NoteSnapScenario.allCases))
    }

    @Test("every matrix case documents user action and expected behavior")
    func casesAreDocumented() {
        for caseItem in NoteSnapAcceptanceMatrix.v1.cases {
            #expect(!caseItem.userAction.isEmpty)
            #expect(!caseItem.expectedBehavior.isEmpty)
        }
    }

    @Test("matrix separates manual acceptance from automated prerequisites")
    func verificationKinds() {
        let matrix = NoteSnapAcceptanceMatrix.v1
        #expect(matrix.manualCases.count == 5)
        #expect(matrix.automatedPrerequisiteCases.count == 7)
    }

    @Test("AeroSpace drag/resize scenario is manual acceptance with no snap prerequisites")
    func aerospaceScenarioIsManual() {
        let aerospaceCase = NoteSnapAcceptanceMatrix.v1.cases.first {
            $0.scenario == .aerospaceDragResize
        }
        #expect(aerospaceCase?.verificationKind == .manualAcceptance)
        #expect(aerospaceCase?.configurationPrerequisites.isEmpty == true)
    }
}

@Suite("NoteSnapGateValidator — automated prerequisites")
struct NoteSnapGateValidatorTests {
    @Test("v1 configuration passes all snap gate prerequisites")
    func v1ConfigurationPasses() {
        let validations = NoteSnapGateValidator.validate(configuration: .v1)
        for validation in validations {
            #expect(validation.passes)
        }
        #expect(NoteSnapGateValidator.allPrerequisitesPass(configuration: .v1))
    }

    @Test("tuned thresholds prerequisite requires 12 pt attraction, 2 pt gap, 15 pt release")
    func tunedThresholds() {
        let validations = NoteSnapGateValidator.validate(configuration: .v1)
        let thresholds = validations.first { $0.prerequisite == .tunedThresholds }
        #expect(thresholds?.passes == true)

        let specDefaults = NoteSnapConfiguration(
            attractionZone: 5,
            snappedGap: 2,
            releaseThreshold: 5
        )
        let failed = NoteSnapGateValidator.validate(configuration: specDefaults)
        let specThresholds = failed.first { $0.prerequisite == .tunedThresholds }
        #expect(specThresholds?.passes == false)
    }

    @Test("zero attraction zone fails side snap behavior prerequisite")
    func zeroAttractionFailsSideSnap() {
        let broken = NoteSnapConfiguration(
            attractionZone: 0,
            snappedGap: 2,
            releaseThreshold: 15
        )
        let validations = NoteSnapGateValidator.validate(configuration: broken)
        let sideSnap = validations.first { $0.prerequisite == .sideSnapBehavior }
        #expect(sideSnap?.passes == false)
    }
}

@Suite("NoteSnapGateValidator — acceptance gate")
struct NoteSnapGateTests {
    @Test("automated snap gate passes for v1 configuration")
    func automatedGatePasses() {
        #expect(NoteSnapGateValidator.automatedSnapGatePasses())
    }

    @Test("each automated matrix case prerequisites pass")
    func automatedCasesPass() {
        let validations = NoteSnapGateValidator.validate(configuration: .v1)
        let passing = Set(validations.filter(\.passes).map(\.prerequisite))

        for caseItem in NoteSnapAcceptanceMatrix.v1.automatedPrerequisiteCases {
            for prerequisite in caseItem.configurationPrerequisites {
                #expect(passing.contains(prerequisite))
            }
        }
    }

    @Test("automated snap gate fails for spec-default thresholds")
    func gateFailsOnSpecDefaults() {
        let specDefaults = NoteSnapConfiguration(
            attractionZone: 5,
            snappedGap: 2,
            releaseThreshold: 5
        )
        #expect(NoteSnapGateValidator.automatedSnapGatePasses(configuration: specDefaults) == false)
    }
}
