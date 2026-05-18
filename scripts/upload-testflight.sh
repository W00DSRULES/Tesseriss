#!/usr/bin/env bash
# Upload the built .ipa to App Store Connect (lands in TestFlight after processing).
#
# Reads from .env.local (gitignored) or environment:
#   ASC_API_KEY_ID         App Store Connect API key ID (10-char, required)
#   ASC_API_ISSUER_ID      ASC API issuer UUID (required)
#   ASC_API_KEY_PATH       Path to AuthKey_<ID>.p8 file (required)
#
# Generate keys at https://appstoreconnect.apple.com → Users and Access → Integrations → App Store Connect API
# Role required: "Developer" or higher. Save the .p8 once — Apple never shows it again.
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -f .env.local ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env.local
  set +a
fi

: "${ASC_API_KEY_ID:?ASC_API_KEY_ID is required}"
: "${ASC_API_ISSUER_ID:?ASC_API_ISSUER_ID is required}"
: "${ASC_API_KEY_PATH:?ASC_API_KEY_PATH is required}"

if [[ ! -f "${ASC_API_KEY_PATH}" ]]; then
  echo "ASC_API_KEY_PATH does not exist: ${ASC_API_KEY_PATH}" >&2
  exit 1
fi

# altool expects the key in ~/.appstoreconnect/private_keys/AuthKey_<ID>.p8
# or ./private_keys/AuthKey_<ID>.p8. We stage it in build/private_keys.
STAGE_DIR="build/private_keys"
mkdir -p "${STAGE_DIR}"
STAGED_KEY="${STAGE_DIR}/AuthKey_${ASC_API_KEY_ID}.p8"
cp "${ASC_API_KEY_PATH}" "${STAGED_KEY}"
chmod 600 "${STAGED_KEY}"

IPA="$(ls build/export/*.ipa 2>/dev/null | head -1)"
if [[ -z "${IPA}" ]]; then
  echo "No .ipa found in build/export/. Run scripts/archive.sh first." >&2
  exit 1
fi

echo "==> Validating ${IPA}"
xcrun altool --validate-app \
  -f "${IPA}" \
  -t ios \
  --apiKey "${ASC_API_KEY_ID}" \
  --apiIssuer "${ASC_API_ISSUER_ID}"

echo "==> Uploading ${IPA} to App Store Connect"
xcrun altool --upload-app \
  -f "${IPA}" \
  -t ios \
  --apiKey "${ASC_API_KEY_ID}" \
  --apiIssuer "${ASC_API_ISSUER_ID}"

echo
echo "Upload accepted. Processing in App Store Connect usually takes 5-30 minutes."
echo "Watch: https://appstoreconnect.apple.com/apps -> Tesseriss -> TestFlight"
