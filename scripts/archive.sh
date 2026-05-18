#!/usr/bin/env bash
# Archive Tesseriss and export an App Store-ready .ipa.
#
# Reads from .env.local (gitignored) or environment:
#   TEAM_ID            Apple Developer Team ID (required)
#   BUNDLE_ID          Override PRODUCT_BUNDLE_IDENTIFIER (optional)
#   MARKETING_VERSION  Override CFBundleShortVersionString (optional)
#   BUILD_NUMBER       Override CFBundleVersion (optional, defaults to unix epoch)
#
# Outputs:
#   build/Tesseriss.xcarchive
#   build/export/Tesseriss.ipa
#   build/export/ExportOptions.plist (with TEAM_ID interpolated)
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -f .env.local ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env.local
  set +a
fi

: "${TEAM_ID:?TEAM_ID is required (set in .env.local or env)}"
BUILD_NUMBER="${BUILD_NUMBER:-$(date +%s)}"

SCHEME="Tesseriss"
PROJECT="Tesseriss.xcodeproj"
BUILD_DIR="build"
ARCHIVE_PATH="${BUILD_DIR}/Tesseriss.xcarchive"
EXPORT_DIR="${BUILD_DIR}/export"
EXPORT_OPTIONS="${EXPORT_DIR}/ExportOptions.plist"

mkdir -p "${EXPORT_DIR}"

if ! command -v xcodegen >/dev/null; then
  echo "xcodegen not found. Install: brew install xcodegen" >&2
  exit 1
fi

echo "==> Regenerating Xcode project"
xcodegen generate

echo "==> Materializing ExportOptions.plist with TEAM_ID"
sed "s/__TEAM_ID__/${TEAM_ID}/g" ExportOptions.plist > "${EXPORT_OPTIONS}"

OVERRIDES=(
  "DEVELOPMENT_TEAM=${TEAM_ID}"
  "CURRENT_PROJECT_VERSION=${BUILD_NUMBER}"
)
if [[ -n "${BUNDLE_ID:-}" ]]; then
  OVERRIDES+=("PRODUCT_BUNDLE_IDENTIFIER=${BUNDLE_ID}")
fi
if [[ -n "${MARKETING_VERSION:-}" ]]; then
  OVERRIDES+=("MARKETING_VERSION=${MARKETING_VERSION}")
fi

echo "==> Archiving (Release, generic iOS device)"
xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "${ARCHIVE_PATH}" \
  "${OVERRIDES[@]}" \
  archive

echo "==> Exporting .ipa"
xcodebuild \
  -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_DIR}" \
  -exportOptionsPlist "${EXPORT_OPTIONS}"

echo
echo "Archive : ${ARCHIVE_PATH}"
echo "IPA     : $(ls "${EXPORT_DIR}"/*.ipa 2>/dev/null | head -1)"
echo "Build # : ${BUILD_NUMBER}"
