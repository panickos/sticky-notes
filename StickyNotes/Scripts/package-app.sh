#!/usr/bin/env bash
# Build a release StickyNotes.app bundle with LSUIElement and bundle ID from DistributionConfiguration.v1.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PACKAGE_DIR}"

CONFIGURATION="${1:-release}"
OUTPUT_DIR="${2:-${PACKAGE_DIR}/dist}"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

echo "Building StickyNotes (${CONFIGURATION})..."
swift build -c "${CONFIGURATION}"

BINARY_PATH="${PACKAGE_DIR}/.build/${CONFIGURATION}/StickyNotes"
if [[ ! -f "${BINARY_PATH}" ]]; then
  echo "error: binary not found at ${BINARY_PATH}" >&2
  exit 1
fi

APP_NAME="StickyNotes"
APP_BUNDLE="${OUTPUT_DIR}/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"

rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS}" "${RESOURCES}"

cp "${BINARY_PATH}" "${MACOS}/${APP_NAME}"
chmod +x "${MACOS}/${APP_NAME}"

"${SCRIPT_DIR}/build-app-icon.sh"
cp "${PACKAGE_DIR}/Resources/AppIcon.icns" "${RESOURCES}/AppIcon.icns"

# Generate Info.plist from DistributionConfiguration.v1 (single source of truth in core).
swift run -c "${CONFIGURATION}" --skip-build GenerateInfoPlist "${CONTENTS}/Info.plist"

echo "Packaged ${APP_BUNDLE}"

if [[ "${SIGN_IDENTITY}" != "skip" ]]; then
  echo "Signing with identity: ${SIGN_IDENTITY}"
  codesign --force --deep --sign "${SIGN_IDENTITY}" "${APP_BUNDLE}"
  codesign --verify --verbose "${APP_BUNDLE}"
  echo "Signed successfully"
fi

echo "Done. Open with: open \"${APP_BUNDLE}\""
