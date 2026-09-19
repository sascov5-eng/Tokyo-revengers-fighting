#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="TokyoRevengersFighting.xcodeproj"
SCHEME="TokyoRevengersFighting"
BUILD_DIR="$ROOT/build"
ARCHIVE="$BUILD_DIR/TokyoRevengersFighting.xcarchive"
IPA="$BUILD_DIR/TokyoRevengersFighting_unsigned.ipa"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  AD_HOC_CODE_SIGNING_ALLOWED=NO

APP="$ARCHIVE/Products/Applications/TokyoRevengersFighting.app"
if [[ ! -d "$APP" ]]; then
  echo "Archive did not produce an .app" >&2
  exit 1
fi

PAYLOAD="$BUILD_DIR/Payload"
rm -rf "$PAYLOAD"
mkdir -p "$PAYLOAD"
cp -R "$APP" "$PAYLOAD/"
rm -f "$IPA"
(
  cd "$BUILD_DIR"
  zip -qr "$(basename "$IPA")" Payload
)
echo "Unsigned IPA: $IPA"
