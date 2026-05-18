#!/usr/bin/env bash
# Bootstrap Tesseriss on App Store Connect, then archive + upload to TestFlight.
#
# Idempotent: safe to re-run. Each step checks current state via the App Store
# Connect API before mutating.
#
# Steps:
#   1. Ensure codemagic-cli-tools is installed (provides `app-store-connect`).
#   2. Register the App ID (Bundle ID) if it does not exist.
#   3. Create the App Store Connect app record if it does not exist.
#   4. Run scripts/archive.sh (archive + export .ipa).
#   5. Run scripts/upload-testflight.sh (validate + upload to TestFlight).
#
# Reads from .env.local (gitignored) or environment:
#   TEAM_ID, BUNDLE_ID, ASC_API_KEY_ID, ASC_API_ISSUER_ID, ASC_API_KEY_PATH (required)
#   APP_NAME, APP_SKU, APP_PRIMARY_LOCALE (optional, sensible defaults below)
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -f .env.local ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env.local
  set +a
fi

: "${TEAM_ID:?TEAM_ID is required (Apple Developer Team ID)}"
: "${BUNDLE_ID:?BUNDLE_ID is required (e.g. com.example.tesseriss)}"
: "${ASC_API_KEY_ID:?ASC_API_KEY_ID is required}"
: "${ASC_API_ISSUER_ID:?ASC_API_ISSUER_ID is required}"
: "${ASC_API_KEY_PATH:?ASC_API_KEY_PATH is required}"
APP_NAME="${APP_NAME:-Tesseriss}"
APP_SKU="${APP_SKU:-tesseriss-ios}"
APP_PRIMARY_LOCALE="${APP_PRIMARY_LOCALE:-en-US}"

if [[ ! -f "${ASC_API_KEY_PATH}" ]]; then
  echo "ASC_API_KEY_PATH does not exist: ${ASC_API_KEY_PATH}" >&2
  exit 1
fi

# --- 1. Ensure codemagic-cli-tools is installed --------------------------------
if ! command -v app-store-connect >/dev/null; then
  echo "==> Installing codemagic-cli-tools (provides app-store-connect CLI)"
  if command -v pipx >/dev/null; then
    pipx install codemagic-cli-tools
  elif command -v brew >/dev/null; then
    brew install pipx && pipx ensurepath
    pipx install codemagic-cli-tools
  else
    echo "Neither pipx nor brew is available. Install one and re-run." >&2
    exit 1
  fi
fi

# codemagic-cli-tools reads these env vars for ASC auth.
export APP_STORE_CONNECT_KEY_IDENTIFIER="${ASC_API_KEY_ID}"
export APP_STORE_CONNECT_ISSUER_ID="${ASC_API_ISSUER_ID}"
export APP_STORE_CONNECT_PRIVATE_KEY="$(cat "${ASC_API_KEY_PATH}")"

# --- 2. Register the App ID if missing -----------------------------------------
echo "==> Checking if Bundle ID ${BUNDLE_ID} is registered"
EXISTING_BUNDLE_ID="$(app-store-connect list-bundle-ids \
  --bundle-id-identifier "${BUNDLE_ID}" \
  --bundle-id-identifier-strict-match \
  --json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data[0]['id'] if data else '')
" || true)"

if [[ -z "${EXISTING_BUNDLE_ID}" ]]; then
  echo "==> Registering Bundle ID ${BUNDLE_ID} (${APP_NAME})"
  app-store-connect register-bundle-id \
    --platform IOS \
    "${BUNDLE_ID}" \
    "${APP_NAME}"
else
  echo "    Bundle ID already registered (resource id ${EXISTING_BUNDLE_ID})"
fi

# --- 3. Create the App Store Connect app record if missing ---------------------
echo "==> Checking if App Store Connect app exists for ${BUNDLE_ID}"
EXISTING_APP="$(app-store-connect apps list \
  --bundle-id-identifier "${BUNDLE_ID}" \
  --json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data[0]['id'] if data else '')
" || true)"

if [[ -z "${EXISTING_APP}" ]]; then
  echo "==> Creating App Store Connect app record"
  echo "    name=${APP_NAME} bundle=${BUNDLE_ID} sku=${APP_SKU} locale=${APP_PRIMARY_LOCALE}"
  # The apps subcommand may not be present in all codemagic-cli-tools versions;
  # fall back to a raw API call if needed.
  if app-store-connect apps create --help >/dev/null 2>&1; then
    app-store-connect apps create \
      --bundle-id "${BUNDLE_ID}" \
      --name "${APP_NAME}" \
      --sku "${APP_SKU}" \
      --primary-locale "${APP_PRIMARY_LOCALE}"
  else
    echo "    app-store-connect apps create not available in installed version."
    echo "    Create the app record once via the web UI:"
    echo "      https://appstoreconnect.apple.com/apps -> + -> New App"
    echo "      Name: ${APP_NAME}  Bundle ID: ${BUNDLE_ID}  SKU: ${APP_SKU}"
    echo "    Then re-run this script."
    exit 1
  fi
else
  echo "    App record already exists (resource id ${EXISTING_APP})"
fi

# --- 4 & 5. Archive + upload ----------------------------------------------------
echo "==> Running archive.sh"
./scripts/archive.sh

echo "==> Running upload-testflight.sh"
./scripts/upload-testflight.sh
