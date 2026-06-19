#!/usr/bin/env bash
# Build AppIcon.icns from Resources/AppIcon-1024.png for the .app bundle.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE="${PACKAGE_DIR}/Resources/AppIcon-1024.png"
ICONSET="${PACKAGE_DIR}/Resources/AppIcon.iconset"
OUTPUT="${PACKAGE_DIR}/Resources/AppIcon.icns"

if [[ ! -f "${SOURCE}" ]]; then
  echo "error: missing source icon at ${SOURCE}" >&2
  exit 1
fi

rm -rf "${ICONSET}"
mkdir -p "${ICONSET}"

declare -a SIZES=(16 32 128 256 512)
for size in "${SIZES[@]}"; do
  sips -z "${size}" "${size}" "${SOURCE}" --out "${ICONSET}/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "${double}" "${double}" "${SOURCE}" --out "${ICONSET}/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "${ICONSET}" -o "${OUTPUT}"
rm -rf "${ICONSET}"

echo "Built ${OUTPUT}"
