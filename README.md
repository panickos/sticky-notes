# Sticky Notes

macOS menu-bar utility: floating sticky notes that stay on top of other windows, with markdown editing, local persistence, global hotkeys, and [AeroSpace](https://github.com/nikitabobko/AeroSpace) compatibility.

## Download

Pre-built releases are on the [Releases](https://github.com/panickos/sticky-notes/releases) page.

1. Download `StickyNotes-<version>.zip`
2. Unzip and drag `StickyNotes.app` to Applications
3. Open from Applications (or right-click → Open the first time if Gatekeeper prompts)

Requires macOS 14 (Sonoma) or later.

## Build from source

```bash
cd StickyNotes
swift test
./Scripts/package-app.sh release
open dist/StickyNotes.app
```

See [StickyNotes/README.md](StickyNotes/README.md) for hotkeys, AeroSpace matrix, and development details.

## Publish a release

From the repo root, after committing your changes:

```bash
./StickyNotes/Scripts/publish-release.sh 1.0.0
```

This runs tests, verifies the release build, tags `v1.0.0`, and pushes to GitHub. A [GitHub Actions workflow](.github/workflows/release.yml) then builds `StickyNotes.app`, zips it, and attaches it to the release.

Options:

- `--skip-tests` — skip `swift test` (not recommended)
- `--skip-build` — skip local release build verification

## Repository layout

| Path | Purpose |
|------|---------|
| `specs/` | Locked product specifications (00–08) |
| `StickyNotes/` | Swift package and macOS app |
| `PROGRESS.md` | Implementation task board |
| `AGENTS.md` | Agent context for AI-assisted development |

## License

Personal project — all rights reserved unless otherwise noted.
