import CoreGraphics

/// Screen-space geometry for a sticky note (Spec 04).
public struct NoteFrame: Codable, Equatable, Sendable {
    public var x: CGFloat
    public var y: CGFloat
    public var width: CGFloat
    public var height: CGFloat

    public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var origin: CGPoint {
        get { CGPoint(x: x, y: y) }
        set {
            x = newValue.x
            y = newValue.y
        }
    }

    public var size: CGSize {
        get { CGSize(width: width, height: height) }
        set {
            width = newValue.width
            height = newValue.height
        }
    }

    public func offset(by delta: CGPoint) -> NoteFrame {
        var copy = self
        copy.x += delta.x
        copy.y += delta.y
        return copy
    }
}
