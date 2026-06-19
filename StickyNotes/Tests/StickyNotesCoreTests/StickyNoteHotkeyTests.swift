import Carbon
import Foundation
import Testing
@testable import StickyNotesCore

@Suite("StickyNoteHotkeyAction — v1 required actions")
struct StickyNoteHotkeyActionTests {
    @Test("catalog defines every required v1 hotkey action")
    func requiredActionsAreCataloged() {
        let required: Set<StickyNoteHotkeyAction> = [
            .toggleVisibility,
            .createNewNote,
        ]
        #expect(StickyNoteHotkeyBindings.requiredActions == required)
    }
}

@Suite("StickyNoteHotkeyBindings — Spec 05 defaults")
struct StickyNoteHotkeyBindingsTests {
    @Test("v1 defaults bind toggle visibility to control-option-N")
    func toggleVisibilityDefault() {
        let bindings = StickyNoteHotkeyBindings.v1Defaults
        let chord = bindings.chord(for: .toggleVisibility)

        #expect(chord.key == "n")
        #expect(chord.modifiers.contains(.control))
        #expect(chord.modifiers.contains(.option))
        #expect(!chord.modifiers.contains(.shift))
        #expect(!chord.modifiers.contains(.command))
    }

    @Test("v1 defaults bind new note to control-option-shift-N")
    func createNewNoteDefault() {
        let bindings = StickyNoteHotkeyBindings.v1Defaults
        let chord = bindings.chord(for: .createNewNote)

        #expect(chord.key == "n")
        #expect(chord.modifiers.contains(.control))
        #expect(chord.modifiers.contains(.option))
        #expect(chord.modifiers.contains(.shift))
    }

    @Test("default chords are macOS Sequoia compatible")
    func defaultsAreSequoiaCompatible() {
        let bindings = StickyNoteHotkeyBindings.v1Defaults
        for action in StickyNoteHotkeyBindings.requiredActions {
            #expect(bindings.chord(for: action).isSequoiaCompatible)
        }
    }

    @Test("default chords have human-readable display strings")
    func displayStrings() {
        let bindings = StickyNoteHotkeyBindings.v1Defaults
        #expect(bindings.chord(for: .toggleVisibility).displayString == "⌃⌥N")
        #expect(bindings.chord(for: .createNewNote).displayString == "⌃⌥⇧N")
    }
}

@Suite("HotkeyChord — Carbon mapping and validation")
struct HotkeyChordTests {
    @Test("maps modifiers to Carbon flags")
    func carbonModifierFlags() {
        let chord = HotkeyChord(key: "n", modifiers: [.control, .option])
        #expect(chord.carbonModifierFlags == UInt32(controlKey | optionKey))
    }

    @Test("maps letter keys to Carbon virtual key codes")
    func carbonKeyCode() {
        let chord = HotkeyChord(key: "n", modifiers: [.control])
        #expect(chord.carbonKeyCode == UInt32(kVK_ANSI_N))
    }

    @Test("rejects option-only chords on macOS Sequoia")
    func rejectsOptionOnly() {
        let chord = HotkeyChord(key: "n", modifiers: [.option])
        #expect(!chord.isSequoiaCompatible)
    }

    @Test("rejects option-shift-only chords on macOS Sequoia")
    func rejectsOptionShiftOnly() {
        let chord = HotkeyChord(key: "n", modifiers: [.option, .shift])
        #expect(!chord.isSequoiaCompatible)
    }

    @Test("accepts control-option chords on macOS Sequoia")
    func acceptsControlOption() {
        let chord = HotkeyChord(key: "n", modifiers: [.control, .option])
        #expect(chord.isSequoiaCompatible)
    }

    @Test("accepts command-shift chords on macOS Sequoia")
    func acceptsCommandShift() {
        let chord = HotkeyChord(key: "n", modifiers: [.command, .shift])
        #expect(chord.isSequoiaCompatible)
    }
}

@Suite("HotkeyLibraryEvaluation — spike decision criteria")
struct HotkeyLibraryEvaluationTests {
    @Test("Carbon RegisterEventHotKey scores higher than CGEvent tap for v1 needs")
    func evaluationRecommendsCarbon() {
        let evaluation = HotkeyLibraryEvaluation.compare()
        #expect(evaluation.recommended == .carbonRegisterEventHotKey)
        #expect(evaluation.carbonScore > evaluation.cgEventTapScore)
    }

    @Test("CGEvent tap requires accessibility permission")
    func cgEventTapRequiresAccessibility() {
        let evaluation = HotkeyLibraryEvaluation.compare()
        #expect(evaluation.carbonPath.requiresAccessibilityPermission == false)
        #expect(evaluation.cgEventTapPath.requiresAccessibilityPermission == true)
    }

    @Test("HotKey library wraps Carbon without adding accessibility requirement")
    func hotKeyLibraryWrapsCarbon() {
        let evaluation = HotkeyLibraryEvaluation.compare()
        #expect(evaluation.hotKeyLibraryPath.usesCarbonUnderHood == true)
        #expect(evaluation.hotKeyLibraryPath.requiresAccessibilityPermission == false)
    }
}
