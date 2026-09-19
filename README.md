# Tokyo Revengers Fighting

Вертикальный 2D-файтинг под iPhone. Сборка без подписи — IPA подписываешь сам.

Сейчас в билде два персонажа, чтобы проверить бой и сенсор:

- **Takemichi** — больше HP, спец «Time Leap» (короткие i-frames + шаг назад)
- **Mikey** — быстрее, сильнее удар ногой, спец «Kick Combo»

P1 всегда снизу слева на стике. Справа кнопки. Второй боец — простой CPU.

## Требования

- Mac + Xcode 15 или новее
- iOS 16+

Xcode на этом репозитории не нужен, чтобы править код. IPA собирается только на Mac.

## Собрать unsigned IPA

```bash
chmod +x Scripts/build_unsigned_ipa.sh
./Scripts/build_unsigned_ipa.sh
```

Готовый файл: `build/TokyoRevengersFighting_unsigned.ipa`

Дальше подписываешь своим сертификатом (zsign, `codesign`, AltStore, Sideloadly, TrollStore — как привык).

Ручная сборка:

```bash
xcodebuild archive \
  -project TokyoRevengersFighting.xcodeproj \
  -scheme TokyoRevengersFighting \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath build/TokyoRevengersFighting.xcarchive \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

APP="build/TokyoRevengersFighting.xcarchive/Products/Applications/TokyoRevengersFighting.app"
rm -rf build/Payload
mkdir -p build/Payload
cp -R "$APP" build/Payload/
cd build && zip -r TokyoRevengersFighting_unsigned.ipa Payload
```

## Управление

- левый стик — влево / вправо
- прыжок — кнопка ↑
- блок — удерживать B
- P — удар рукой
- K — удар ногой
- S — спец приём

Победа: чужое HP в ноль. После KO тап по экрану — реванш.

## Bundle

- Display name: TR Fighting
- Bundle ID: `com.sascov5.TokyoRevengersFighting`
- Ориентация: только portrait
- Устройства: iPhone

## Что не входит в этот шаг

Спрайты, арены, остальные персонажи, сюжет, онлайн. Сначала проверяем, что архив собирается и бой на пальцах живой.
