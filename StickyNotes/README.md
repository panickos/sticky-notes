# StickyNotes — macOS Menu Bar App

Swift package for always-on-top sticky notes with markdown, local persistence, global hotkeys, and AeroSpace compatibility.

## Build & test

```bash
cd StickyNotes
swift test          # 107 automated tests
swift build         # compile debug binary
.build/debug/StickyNotes   # run without .app wrapper (uses .accessory activation policy)
```

## Package as .app (Task 2.0)

```bash
cd StickyNotes
./Scripts/package-app.sh release          # builds dist/StickyNotes.app (ad-hoc signed)
SIGN_IDENTITY="Developer ID Application: …" ./Scripts/package-app.sh release  # developer sign
open dist/StickyNotes.app
```

Bundle ID: `dev.stickynotes.app` (from `DistributionConfiguration.v1`). Info.plist includes `LSUIElement` for no dock icon.

## App shell (Task 1.0)

Menu bar accessory app (Spec 05):

| Menu item | Action |
|-----------|--------|
| Hide Notes / Show Notes | Toggle all note panels (mirrors `⌃⌥N`) |
| New Note | Create a new note panel (mirrors `⌃⌥⇧N`) |
| Quit | Terminate the app |

Manual check: note icon in menu bar, no dock icon; menu show/hide title updates after hotkey toggle.

## Markdown spike (Task 0.2)

The spike app shows a **live markdown preview** above a `TextEditor`:

- **Renderer:** [MarkdownUI](https://github.com/gonzalezreal/swift-markdown-ui) (SwiftUI GFM)
- **Parser/analysis:** [swift-markdown](https://github.com/swiftlang/swift-markdown) (cmark-gfm) in `StickyNotesCore`

Manual check: type in the editor and confirm headings, bold/italic, lists, task items, links, code, and blockquotes update the preview instantly.

## Global hotkey spike (Task 0.3)

Carbon `RegisterEventHotKey` via `CarbonGlobalHotkeyRegistry` in `StickyNotesCore`:

| Shortcut | Action |
|----------|--------|
| `⌃⌥N` | Toggle show/hide all note panels |
| `⌃⌥⇧N` | Create a new note panel |

Manual check (from another app, e.g. Chrome or Terminal):

- `⌃⌥N` hides all notes; press again to restore
- `⌃⌥⇧N` adds another offset note
- No Accessibility permission prompt required
- Shortcut hints appear in each note header

**Sequoia note:** global hotkeys must include Control or Command — Option-only chords are blocked by macOS 15+.

## AeroSpace compatibility (Task 0.1 / 1.3.4)

Note panels use `NSPanel` with AeroSpace-tuned configuration. Manual Spec 08 matrix **confirmed 2026-06-18**.

### Manual verification (Spec 08 matrix)

Run with AeroSpace active. Walk all six scenarios from `AerospaceCompatibilityMatrix.v1`:

| Scenario | Expected |
|----------|----------|
| Focus a tiled app (Chrome, Terminal) | Notes stay visible above it |
| Switch AeroSpace workspace | Notes remain visible on new workspace, same position |
| Toggle tiling ↔ floating on another app | Notes unaffected |
| Create / drag / resize a note | AeroSpace does not snap or retile |
| Press `⌃⌥N` from any workspace | All notes hide; press again to restore |
| Multi-monitor (if available) | Notes stay on correct screen, on top |

Automated prerequisite validation: `AerospaceConfigurationValidator` (10 tests in `StickyNoteAerospaceCompatibilityTests`).

## Window configuration (automated invariants)

See `NotePanelConfiguration.aerospaceCompatible`:

- **Level:** `.statusBar` (25) — set *after* `isFloatingPanel` or AppKit resets to `.floating` (3)
- **Collection behavior:** `canJoinAllSpaces`, `fullScreenAuxiliary`, `stationary`, `ignoresCycle`
- **Style:** borderless, non-activating, resizable panel

## Optional AeroSpace config

Add to `~/.aerospace.toml` (bundle ID from `DistributionConfiguration.v1`):

```toml
[[on-window-detected]]
if.app-id = 'dev.stickynotes.app'
run = ['layout floating']
```

Spike works without this config; it is belt-and-suspenders only (Spec 08).
