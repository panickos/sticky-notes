import Carbon

/// Modifier keys for a global hotkey chord.
public struct HotkeyModifier: OptionSet, Sendable, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let control = HotkeyModifier(rawValue: 1 << 0)
    public static let option = HotkeyModifier(rawValue: 1 << 1)
    public static let shift = HotkeyModifier(rawValue: 1 << 2)
    public static let command = HotkeyModifier(rawValue: 1 << 3)

    public var carbonFlags: UInt32 {
        var flags: UInt32 = 0
        if contains(.control) { flags |= UInt32(controlKey) }
        if contains(.option) { flags |= UInt32(optionKey) }
        if contains(.shift) { flags |= UInt32(shiftKey) }
        if contains(.command) { flags |= UInt32(cmdKey) }
        return flags
    }

    public var displaySymbol: String {
        var parts: [String] = []
        if contains(.control) { parts.append("⌃") }
        if contains(.option) { parts.append("⌥") }
        if contains(.shift) { parts.append("⇧") }
        if contains(.command) { parts.append("⌘") }
        return parts.joined()
    }
}
