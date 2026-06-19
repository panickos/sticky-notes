# Sticky Notes — Spec Index

Interview completed 2026-06-12. All specs approved 2026-06-12.

| Spec | Topic | Status |
|------|-------|--------|
| [01-core-vision](./01-core-vision.md) | Problem, user, success criteria | ✅ Approved |
| [02-platform-overlay](./02-platform-overlay.md) | macOS overlay, always-on-top, show/hide | ✅ Approved |
| [03-note-model](./03-note-model.md) | Content, actions, appearance | ✅ Approved |
| [04-persistence](./04-persistence.md) | Storage, autosave, session restore | ✅ Approved |
| [05-system-integration](./05-system-integration.md) | Menu bar, hotkeys, launch | ✅ Approved |
| [06-tech-stack](./06-tech-stack.md) | Native Swift implementation | ✅ Approved |
| [07-v1-boundaries](./07-v1-boundaries.md) | In/out of scope, definition of done | ✅ Approved |
| [08-aerospace-compatibility](./08-aerospace-compatibility.md) | AeroSpace WM overlay behavior | ✅ Approved |

## Resolved decisions (final)

- **Non-goals:** Cloud sync, sharing, attachments, Windows/Linux — confirmed complete; no additional exclusions
- **Launch visibility:** Notes always **visible** on relaunch (hidden state is not persisted across app restarts)

## Next step

Implementation started 2026-06-18. **Phase 1 feature build complete** — all spikes and Spec 01–08 acceptance met; AeroSpace manual matrix confirmed. See [PROGRESS.md](../PROGRESS.md).
