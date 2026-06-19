/// Spike evaluation comparing Carbon RegisterEventHotKey vs HotKey library vs CGEvent tap.
public enum HotkeyImplementationChoice: String, Sendable {
    case carbonRegisterEventHotKey
    case hotKeyLibrary
    case cgEventTap
}

public struct HotkeyImplementationPath: Equatable, Sendable {
    public let name: String
    public let requiresAccessibilityPermission: Bool
    public let usesCarbonUnderHood: Bool
    public let integrationEffort: Int
    public let integrationScore: Int

    public init(
        name: String,
        requiresAccessibilityPermission: Bool,
        usesCarbonUnderHood: Bool,
        integrationEffort: Int,
        integrationScore: Int
    ) {
        self.name = name
        self.requiresAccessibilityPermission = requiresAccessibilityPermission
        self.usesCarbonUnderHood = usesCarbonUnderHood
        self.integrationEffort = integrationEffort
        self.integrationScore = integrationScore
    }

    public var totalScore: Int {
        var score = integrationScore
        if !requiresAccessibilityPermission { score += 3 }
        if usesCarbonUnderHood { score += 1 }
        score -= integrationEffort
        return score
    }
}

public struct HotkeyLibraryEvaluation: Equatable, Sendable {
    public let recommended: HotkeyImplementationChoice
    public let carbonPath: HotkeyImplementationPath
    public let hotKeyLibraryPath: HotkeyImplementationPath
    public let cgEventTapPath: HotkeyImplementationPath
    public let carbonScore: Int
    public let hotKeyLibraryScore: Int
    public let cgEventTapScore: Int
    public let rationale: String

    public static func compare() -> HotkeyLibraryEvaluation {
        let carbon = HotkeyImplementationPath(
            name: "Carbon RegisterEventHotKey (direct)",
            requiresAccessibilityPermission: false,
            usesCarbonUnderHood: true,
            integrationEffort: 2,
            integrationScore: 5
        )

        let hotKeyLibrary = HotkeyImplementationPath(
            name: "HotKey library (soffes/HotKey — Carbon wrapper)",
            requiresAccessibilityPermission: false,
            usesCarbonUnderHood: true,
            integrationEffort: 1,
            integrationScore: 4
        )

        let cgEventTap = HotkeyImplementationPath(
            name: "CGEvent tap (global event monitor)",
            requiresAccessibilityPermission: true,
            usesCarbonUnderHood: false,
            integrationEffort: 4,
            integrationScore: 2
        )

        let carbonScore = carbon.totalScore
        let hotKeyLibraryScore = hotKeyLibrary.totalScore
        let cgEventTapScore = cgEventTap.totalScore

        let recommended: HotkeyImplementationChoice
        if carbonScore >= hotKeyLibraryScore && carbonScore >= cgEventTapScore {
            recommended = .carbonRegisterEventHotKey
        } else if hotKeyLibraryScore >= cgEventTapScore {
            recommended = .hotKeyLibrary
        } else {
            recommended = .cgEventTap
        }

        return HotkeyLibraryEvaluation(
            recommended: recommended,
            carbonPath: carbon,
            hotKeyLibraryPath: hotKeyLibrary,
            cgEventTapPath: cgEventTap,
            carbonScore: carbonScore,
            hotKeyLibraryScore: hotKeyLibraryScore,
            cgEventTapScore: cgEventTapScore,
            rationale: """
            Carbon RegisterEventHotKey registers global hotkeys without Accessibility permission \
            and is sufficient for v1's two fixed shortcuts. The HotKey library is a thin Carbon \
            wrapper with slightly less boilerplate but adds a dependency. CGEvent tap can intercept \
            arbitrary keys but requires Accessibility approval and is overkill for toggle/new-note.
            """
        )
    }
}
