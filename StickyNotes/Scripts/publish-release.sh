#!/usr/bin/env bash
# Tag and push a release. GitHub Actions builds StickyNotes.app and publishes the zip.
#
# Usage:
#   ./Scripts/publish-release.sh <version> [--skip-tests] [--skip-build]
#
# Examples:
#   ./Scripts/publish-release.sh 1.0.0
#   ./Scripts/publish-release.sh 1.0.1 --skip-tests
#
# Version must match DistributionConfiguration.v1.bundleVersion (semver MAJOR.MINOR.PATCH; currently 1.0.0).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${PACKAGE_DIR}/.." && pwd)"

SKIP_TESTS=0
SKIP_BUILD=0
VERSION=""

for arg in "$@"; do
  case "${arg}" in
    --skip-tests) SKIP_TESTS=1 ;;
    --skip-build) SKIP_BUILD=1 ;;
    -h|--help)
      sed -n '2,12p' "${BASH_SOURCE[0]}"
      exit 0
      ;;
    -*)
      echo "error: unknown option ${arg}" >&2
      exit 1
      ;;
    *)
      if [[ -z "${VERSION}" ]]; then
        VERSION="${arg}"
      else
        echo "error: unexpected argument ${arg}" >&2
        exit 1
      fi
      ;;
  esac
done

if [[ -z "${VERSION}" ]]; then
  echo "error: version required (e.g. 1.0.0)" >&2
  exit 1
fi

TAG="v${VERSION}"

cd "${PACKAGE_DIR}"

if [[ "${SKIP_TESTS}" -eq 0 ]]; then
  echo "Running tests..."
  swift test
fi

if [[ "${SKIP_BUILD}" -eq 0 ]]; then
  echo "Verifying release build..."
  "${SCRIPT_DIR}/package-app.sh" release
fi

cd "${REPO_ROOT}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: not a git repository" >&2
  exit 1
fi

if git rev-parse "${TAG}" >/dev/null 2>&1; then
  echo "error: tag ${TAG} already exists" >&2
  exit 1
fi

CURRENT_BRANCH="$(git branch --show-current)"
if [[ "${CURRENT_BRANCH}" != "main" ]]; then
  echo "warning: current branch is '${CURRENT_BRANCH}', expected 'main'" >&2
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree has uncommitted changes; commit before publishing" >&2
  git status --short
  exit 1
fi

echo "Creating tag ${TAG}..."
git tag -a "${TAG}" -m "Release ${TAG}"

echo "Pushing branch and tag..."
git push origin HEAD
git push origin "${TAG}"

REPO_URL="$(gh repo view --json url --jq '.url' 2>/dev/null || echo 'https://github.com/panickos/sticky-notes')"
echo ""
echo "Tagged and pushed ${TAG}."
echo "GitHub Actions will build StickyNotes.app and publish StickyNotes-${VERSION}.zip."
echo "Track progress: ${REPO_URL}/actions"
echo "Release page:   ${REPO_URL}/releases/tag/${TAG}"
