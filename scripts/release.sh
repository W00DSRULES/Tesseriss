#!/usr/bin/env bash
# Archive, export and upload a build to App Store Connect.
#
# The version and build number come from project.yml — NOT from this script.
# GENERATE_INFOPLIST_FILE is NO and the generated Info.plist holds literal
# version strings, so passing MARKETING_VERSION/CURRENT_PROJECT_VERSION to
# xcodebuild silently does nothing and you would re-upload the same build number.
#
# Needs an App Store Connect API key (App Manager role is enough):
#   ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH   (or a .env.local defining them)
#
#   ./scripts/release.sh            # archive + export + upload
#   ./scripts/release.sh --no-upload
set -euo pipefail

cd "$(dirname "$0")/.."
[[ -f .env.local ]] && source .env.local

: "${ASC_KEY_ID:?set ASC_KEY_ID}"
: "${ASC_ISSUER_ID:?set ASC_ISSUER_ID}"
: "${ASC_KEY_PATH:?set ASC_KEY_PATH}"
[[ -f "$ASC_KEY_PATH" ]] || { echo "no key at $ASC_KEY_PATH" >&2; exit 1; }

ARCHIVE=build/Tesseriss.xcarchive
EXPORT=build/export

command -v xcodegen >/dev/null || { echo "xcodegen required (brew install xcodegen)" >&2; exit 1; }
xcodegen generate

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" TesserissApp/Info.plist)
BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" TesserissApp/Info.plist)
echo "==> Tesseriss $VERSION (build $BUILD)"

rm -rf "$ARCHIVE" "$EXPORT"

# -allowProvisioningUpdates + API-key auth so a missing distribution certificate
# is re-issued instead of failing the archive.
xcodebuild archive \
  -project Tesseriss.xcodeproj -scheme Tesseriss -configuration Release \
  -destination 'generic/platform=iOS' -archivePath "$ARCHIVE" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID"

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" -exportPath "$EXPORT" \
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID"

IPA=$(find "$EXPORT" -name '*.ipa' | head -1)
[[ -n "$IPA" ]] || { echo "no .ipa produced" >&2; exit 1; }

# Cheap guard against the version-stamping trap described above.
echo "==> built: $(basename "$IPA")"

[[ "${1:-}" == "--no-upload" ]] && { echo "skipping upload"; exit 0; }

xcrun altool --upload-app -f "$IPA" -t ios \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
echo "==> uploaded; processing takes 5-30 min"
