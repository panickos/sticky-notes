import Carbon

public typealias HotkeyHandler = @Sendable () -> Void

public enum CarbonHotkeyRegistrationError: Error, Equatable, Sendable {
    case sequoiaIncompatible(HotkeyChord)
    case registrationFailed(OSStatus)
}

/// Registers global hotkeys via Carbon `RegisterEventHotKey`.
public final class CarbonGlobalHotkeyRegistry: @unchecked Sendable {
    private var hotKeyRefs: [EventHotKeyRef?] = []
    private var eventHandler: EventHandlerRef?
    private var handlersByID: [UInt32: HotkeyHandler] = [:]
    private let handlerQueue: DispatchQueue

    public init(handlerQueue: DispatchQueue = .main) {
        self.handlerQueue = handlerQueue
    }

    deinit {
        unregisterAll()
    }

    public func register(
        bindings: StickyNoteHotkeyBindings,
        handlers: [StickyNoteHotkeyAction: HotkeyHandler]
    ) throws {
        unregisterAll()

        var handlersByID: [UInt32: HotkeyHandler] = [:]
        for action in StickyNoteHotkeyBindings.requiredActions {
            guard let handler = handlers[action] else {
                continue
            }
            handlersByID[action.hotKeyID] = handler
        }
        self.handlersByID = handlersByID

        try installEventHandler()

        for action in StickyNoteHotkeyBindings.requiredActions {
            guard handlers[action] != nil else { continue }
            let chord = bindings.chord(for: action)
            try register(chord: chord, id: action.hotKeyID)
        }
    }

    public func unregisterAll() {
        for ref in hotKeyRefs {
            if let ref {
                UnregisterEventHotKey(ref)
            }
        }
        hotKeyRefs.removeAll()

        if let eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }

        handlersByID.removeAll()
    }

    private func register(chord: HotkeyChord, id: UInt32) throws {
        guard chord.isSequoiaCompatible else {
            throw CarbonHotkeyRegistrationError.sequoiaIncompatible(chord)
        }

        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            chord.carbonKeyCode,
            chord.carbonModifierFlags,
            EventHotKeyID(signature: HotkeySignature.value, id: id),
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr, let hotKeyRef else {
            throw CarbonHotkeyRegistrationError.registrationFailed(status)
        }

        hotKeyRefs.append(hotKeyRef)
    }

    private func installEventHandler() throws {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData -> OSStatus in
                guard
                    let userData,
                    let registry = Unmanaged<CarbonGlobalHotkeyRegistry>
                        .fromOpaque(userData)
                        .takeUnretainedValue() as CarbonGlobalHotkeyRegistry?
                else {
                    return OSStatus(eventNotHandledErr)
                }

                var hotKeyID = EventHotKeyID()
                let error = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                guard error == noErr else {
                    return OSStatus(eventNotHandledErr)
                }

                registry.handleHotKey(id: hotKeyID.id)
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )

        guard status == noErr else {
            throw CarbonHotkeyRegistrationError.registrationFailed(status)
        }
    }

    private func handleHotKey(id: UInt32) {
        guard let handler = handlersByID[id] else { return }
        handlerQueue.async(execute: handler)
    }
}

private enum HotkeySignature {
    static let value: OSType = 0x534E_484B // 'SNHK'
}

private extension StickyNoteHotkeyAction {
    var hotKeyID: UInt32 {
        switch self {
        case .toggleVisibility: 1
        case .createNewNote: 2
        }
    }
}
