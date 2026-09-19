# Tokyo Revengers Fighting

Вертикальный 2D-файтинг под iPhone. IPA без подписи — подписываешь в ESign.

## Скачать IPA с GitHub (Mac не нужен)

1. Открой [Actions](https://github.com/sascov5-eng/Tokyo-revengers-fighting/actions).
2. Слева выбери **Build unsigned IPA**.
3. Дождись зелёной галки (обычно 5–12 минут).
4. Внизу у успешного рана — **Artifacts** → `TokyoRevengersFighting-unsigned`.
5. Скачается zip. Внутри файл `TokyoRevengersFighting_unsigned.ipa`.
6. Кинь этот `.ipa` в ESign и подпиши сам.

Ручной пересбор: Actions → Build unsigned IPA → **Run workflow** → Run workflow.

Артефакт живёт 14 дней.

## Локально с Mac

```bash
chmod +x Scripts/build_unsigned_ipa.sh
./Scripts/build_unsigned_ipa.sh
```

Файл: `build/TokyoRevengersFighting_unsigned.ipa`

## Bundle

- Display name: TR Fighting
- Bundle ID: `com.sascov5.TokyoRevengersFighting`
- Ориентация: portrait
- iOS 16+, iPhone
