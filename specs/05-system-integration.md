# Spec 05: System Integration

**Status:** ✅ Approved  
**Depends on:** [02-platform-overlay](./02-platform-overlay.md), [04-persistence](./04-persistence.md)

## App presence

| Requirement | Value |
|-------------|-------|
| Dock icon | **None** — menu bar only (LSUIElement / accessory app) |
| Menu bar icon | **Required** — primary entry point when notes are hidden |
| Quit | Menu bar → Quit (standard Cmd+Q behavior) |

## Menu bar actions (minimum)

- Show / Hide notes (mirrors global hotkey)
- New note
- Quit

## Global hotkeys

| Hotkey | Required v1 |
|--------|-------------|
| Toggle show/hide all notes | ✅ (default shortcut chosen by app) |
| Create new note | ✅ |
| User-configurable shortcuts | Nice-to-have; sensible defaults acceptable for v1 |

## Suggested defaults (for implementation — user may override later)

| Action | Suggested shortcut |
|--------|-------------------|
| Toggle visibility | `⌃⌥N` or `⌘⇧N` (avoid conflicts — validate on install) |
| New note | `⌃⌥⇧N` |

## macOS permissions

Likely required:

- **Accessibility** — global hotkey monitoring (if using global event tap)
- Document actual permission prompts in implementation notes

## Verification

- [x] Menu bar only (no dock)
- [x] Global hotkey: toggle visibility
- [x] Global hotkey: new note
- [x] Menu bar: show/hide, new note, quit
- [x] Exact default shortcuts — `⌃⌥N` toggle visibility, `⌃⌥⇧N` new note (confirmed in Task 0.3 spike)
- [x] Launch visibility resets to visible on relaunch — see [04-persistence](./04-persistence.md)
