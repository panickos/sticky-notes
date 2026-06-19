# Spec 06: Tech Stack

**Status:** ✅ Approved  
**Depends on:** [02-platform-overlay](./02-platform-overlay.md)

## Decision

| Layer | Choice |
|-------|--------|
| Language | **Swift** |
| UI framework | **SwiftUI** (preferred for v1) |
| App type | Menu bar accessory + borderless floating panels |
| Markdown rendering | **MarkdownUI** (SwiftUI GFM renderer) + swift-markdown (cmark-gfm parsing/analysis) |
| Persistence | Codable models + FileManager (Application Support) |

## Key technical challenges (spikes needed)

1. **Always-on-top floating windows** — `NSPanel` with `.floating` / `.statusBar` level
2. **Borderless chrome with hover controls** — custom SwiftUI overlay
3. **Global hotkeys** — **Carbon RegisterEventHotKey** (direct; no Accessibility permission)
4. **Live markdown preview** — editor + renderer performance in small windows
5. **Multi-monitor coordinates** — save/restore per `NSScreen`
6. **AeroSpace compatibility** — window level, `NSPanel`, collection behavior; see [08-aerospace-compatibility](./08-aerospace-compatibility.md)

## Non-goals (technical)

- Cross-platform abstraction layers
- Electron/Tauri/webview embedding
- Cloud sync infrastructure

## Verification

- [x] Native Swift/SwiftUI on macOS
- [x] Markdown library choice — **MarkdownUI** (rendering) + swift-markdown (parsing/analysis)
- [x] Global hotkey implementation — **Carbon RegisterEventHotKey** (defaults: `⌃⌥N` toggle, `⌃⌥⇧N` new note)
- [x] AeroSpace overlay behavior — manual Spec 08 matrix confirmed 2026-06-18
