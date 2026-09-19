#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="TokyoRevengersFighting.xcodeproj"
SCHEME="TokyoRevengersFighting"
BUILD_DIR="$ROOT/build"
DERIVED="$BUILD_DIR/DerivedData"
IPA="$BUILD_DIR/TokyoRevengersFighting_unsigned.ipa"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Archive with signing off often fails on CI. Build the device .app, then zip Payload.
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="" \
  PROVISIONING_PROFILE_SPECIFIER=""

APP="$(find "$DERIVED/Build/Products" -name 'TokyoRevengersFighting.app' -type d | head -n 1)"
if [[ -z "$APP" || ! -d "$APP" ]]; then
  echo "Build did not produce TokyoRevengersFighting.app" >&2
  find "$DERIVED/Build/Products" -maxdepth 3 -print >&2 || true
  exit 1
fi

echo "APP=$APP"
PAYLOAD="$BUILD_DIR/Payload"
rm -rf "$PAYLOAD"
mkdir -p "$PAYLOAD"
cp -R "$APP" "$PAYLOAD/"
# Drop bitcode/dSYMs noise if copied alongside
rm -f "$IPA"
(
  cd "$BUILD_DIR"
  zip -qr "$(basename "$IPA")" Payload
)
ls -lh "$IPA"
echo "Unsigned IPA: $IPA"
