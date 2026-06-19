import Carbon

/// A single global hotkey combination (key + modifiers).
public struct HotkeyChord: Equatable, Sendable, Hashable {
    public let key: Character
    public let modifiers: HotkeyModifier

    public init(key: Character, modifiers: HotkeyModifier) {
        self.key = key
        self.modifiers = modifiers
    }

    public var carbonKeyCode: UInt32 {
        HotkeyVirtualKeyCode.carbonKeyCode(for: key)
    }

    public var carbonModifierFlags: UInt32 {
        modifiers.carbonFlags
    }

    /// macOS Sequoia+ rejects hotkeys whose only modifiers are Option and/or Shift.
    public var isSequoiaCompatible: Bool {
        modifiers.contains(.control) || modifiers.contains(.command)
    }

    public var displayString: String {
        modifiers.displaySymbol + key.uppercased()
    }
}

enum HotkeyVirtualKeyCode {
    static func carbonKeyCode(for key: Character) -> UInt32 {
        switch key.lowercased().first {
        case "a": UInt32(kVK_ANSI_A)
        case "b": UInt32(kVK_ANSI_B)
        case "c": UInt32(kVK_ANSI_C)
        case "d": UInt32(kVK_ANSI_D)
        case "e": UInt32(kVK_ANSI_E)
        case "f": UInt32(kVK_ANSI_F)
        case "g": UInt32(kVK_ANSI_G)
        case "h": UInt32(kVK_ANSI_H)
        case "i": UInt32(kVK_ANSI_I)
        case "j": UInt32(kVK_ANSI_J)
        case "k": UInt32(kVK_ANSI_K)
        case "l": UInt32(kVK_ANSI_L)
        case "m": UInt32(kVK_ANSI_M)
        case "n": UInt32(kVK_ANSI_N)
        case "o": UInt32(kVK_ANSI_O)
        case "p": UInt32(kVK_ANSI_P)
        case "q": UInt32(kVK_ANSI_Q)
        case "r": UInt32(kVK_ANSI_R)
        case "s": UInt32(kVK_ANSI_S)
        case "t": UInt32(kVK_ANSI_T)
        case "u": UInt32(kVK_ANSI_U)
        case "v": UInt32(kVK_ANSI_V)
        case "w": UInt32(kVK_ANSI_W)
        case "x": UInt32(kVK_ANSI_X)
        case "y": UInt32(kVK_ANSI_Y)
        case "z": UInt32(kVK_ANSI_Z)
        default:
            fatalError("Unsupported hotkey key: \(key)")
        }
    }
}
