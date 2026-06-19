import CoreGraphics
import Foundation

/// Persisted sticky-note record (Spec 04).
public struct StickyNote: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var content: String
    public var frame: NoteFrame
    public var color: NoteColor
    public var zIndex: Int
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID,
        content: String,
        frame: NoteFrame,
        color: NoteColor,
        zIndex: Int,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.content = content
        self.frame = frame
        self.color = color
        self.zIndex = zIndex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public static func new(
        at origin: CGPoint,
        zIndex: Int,
        content: String = "",
        color: NoteColor = NoteAppearanceDefaults.defaultColor,
        now: Date = Date()
    ) -> StickyNote {
        StickyNote(
            id: UUID(),
            content: content,
            frame: NoteFrame(
                x: origin.x,
                y: origin.y,
                width: NoteAppearanceDefaults.defaultWidth,
                height: NoteAppearanceDefaults.defaultHeight
            ),
            color: color,
            zIndex: zIndex,
            createdAt: now,
            updatedAt: now
        )
    }

    public mutating func touchContent(_ content: String, at date: Date = Date()) {
        self.content = content
        updatedAt = date
    }

    public mutating func touchFrame(_ frame: NoteFrame, at date: Date = Date()) {
        self.frame = frame
        updatedAt = date
    }

    public mutating func touchColor(_ color: NoteColor, at date: Date = Date()) {
        self.color = color
        updatedAt = date
    }

    public mutating func touchZIndex(_ zIndex: Int, at date: Date = Date()) {
        self.zIndex = zIndex
        updatedAt = date
    }

    public func duplicate(
        nextZIndex: Int,
        offset: CGPoint = CGPoint(x: 28, y: -28),
        now: Date = Date()
    ) -> StickyNote {
        StickyNote(
            id: UUID(),
            content: content,
            frame: frame.offset(by: offset),
            color: color,
            zIndex: nextZIndex,
            createdAt: createdAt,
            updatedAt: now
        )
    }
}
