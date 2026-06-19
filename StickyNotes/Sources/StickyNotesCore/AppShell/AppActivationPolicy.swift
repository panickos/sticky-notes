/// macOS activation policy for app presence (Spec 05 — no dock icon).
public enum AppActivationPolicy: String, Sendable, Equatable {
    /// Menu bar only; no dock icon (LSUIElement / `.accessory`).
    case accessory
}
