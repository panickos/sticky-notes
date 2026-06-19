# Spec 04: Persistence

**Status:** ✅ Approved  
**Depends on:** [03-note-model](./03-note-model.md)

## Storage

| Requirement | Value |
|-------------|-------|
| Backend | **Local only** — no network, no accounts |
| Location | **macOS Application Support** (standard app container) |
| Format | Implementation choice (JSON recommended for inspectability) |
| User-picked paths | Not required in v1 |

## Autosave

| Requirement | Value |
|-------------|-------|
| Strategy | **Debounced** auto-save (~1–2 s after last change) |
| Manual save | Not required (autosave is sufficient) |
| Save triggers | Content, position, size, color, z-order |

## Session restore

| Requirement | Value |
|-------------|-------|
| On launch | **Restore all notes** from last session (content, position, size, color) |
| Initial visibility | **Always visible** on launch — reset to default (do not restore hidden state from last session) |
| Crash recovery | Best-effort from last successful save |

## Data model (minimum fields per note)

```
id: UUID
content: String (markdown source)
x, y: CGFloat (screen coordinates)
width, height: CGFloat
color: enum / string (palette key)
zIndex: Int (stacking order)
createdAt, updatedAt: Date
```

## Verification

- [x] Application Support storage
- [x] Debounced autosave
- [x] Full session restore on launch
- [x] Launch visibility resets to visible (default)
