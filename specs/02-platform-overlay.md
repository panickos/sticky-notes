# Spec 02: Platform & Overlay Behavior

**Status:** ✅ Approved  
**Depends on:** [01-core-vision](./01-core-vision.md)

## Platform

| Requirement | Value |
|-------------|-------|
| OS | **macOS only** (v1) |
| Distribution | TBD (developer build vs signed .app) |
| Windows / Linux | Out of scope for v1 |

## Window behavior

| Requirement | Value |
|-------------|-------|
| Z-order | Notes are **always on top** of other application windows |
| Screen coverage | Notes can be placed anywhere on the display(s) |
| Multi-monitor | Assume standard macOS multi-display support (details in implementation) |
| AeroSpace WM | Must work identically with AeroSpace running — see [08-aerospace-compatibility](./08-aerospace-compatibility.md) |

## Show / hide (global)

| Requirement | Value |
|-------------|-------|
| Trigger | **Global hotkey** toggles visibility of the entire note set |
| Default shortcut | App chooses sensible default; user can change later (not required day-one config UI) |
| Hidden state | All notes invisible; app continues running |
| Visible state | All notes restored to prior positions/sizes/content |

## Verification

- [x] macOS only
- [x] Always on top
- [x] Global hotkey toggle (not dock-minimize-only)
- [ ] Multi-monitor edge cases — confirm during implementation review
- [ ] AeroSpace compatibility — see [08-aerospace-compatibility](./08-aerospace-compatibility.md)
