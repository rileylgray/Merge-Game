# Mergelings

A merge-and-collect idle game for iOS and Android. The basket fills on its own
and drops a creature every time it brims over — tap it to fill it faster — then
drag two matching creatures together to merge them into the next species, and
fill five meadows with 150 friends.

- **Bundle id** — `com.realgamesrealfun.mergelings`
- **Platforms** — iOS and Android only
- **Languages** — English, Spanish, Portuguese, French, German
- **Built with** — Flutter 3.38.9 / Dart 3.10.8

---

## Quick start

```bash
flutter pub get
flutter run
```

Debug and profile builds use Google's public AdMob **test** units, so no real
ad inventory is touched during development. Release builds use the live units
automatically. See [Shipping](#shipping) before releasing.

---

## Design notes

Two things about this project are unusual and worth understanding before
changing anything.

### All artwork is drawn in code

There are no image assets for the creatures. Every one of the 150 is described
as a `CreatureSpec` — a set of enums for body shape, ears, crest, tail, wings,
snout, pattern, eyes, limbs and one accent flourish — and rendered by a single
`CustomPainter`.

The payoff: crisp at any resolution, near-zero bundle cost, and one style
change propagates to the whole cast at once. The cost: silhouettes are
combinatorial, so a new part type must be checked against every creature that
uses it.

### All sound is generated in code

The six sound cues are synthesised as 16-bit PCM WAV by `tool/generate_sfx.dart`
— additive bell partials and pitch sweeps with exponential envelopes. Same
tradeoff as the art: no licensed binary assets, tiny bundle, tweak-and-rerun.

The background music comes from `tool/generate_music.dart` on the same terms: a
32-second pastoral pad in D major — drone, four crossfading chords, sparse
pentatonic melody. It is the one place the "tiny bundle" claim bends: 1.35 MB,
where every other asset in the app put together is under 250 KB. It is written
at 22.05 kHz rather than 44.1 for exactly that reason — nothing in the piece
goes above about 3 kHz, so the extra bandwidth would be paid for in megabytes
and heard by nobody.

**The loop is seamless by construction, not by fading.** Two rules do it, and
both matter if you change the piece:

1. Every sustained frequency is snapped to an exact multiple of `1 / 32 Hz`, so
   each voice completes a whole number of cycles per lap and comes back to the
   phase it started at. The grid is fine enough that nothing moves by more than
   a thousandth of a semitone.
2. Every decaying note is written with wrap-around, so a tail running past the
   end of the buffer folds onto the opening instead of being chopped at the
   join.

The chord swells are Hann windows overlapped by half, which sum to a constant —
that is what keeps the bed from throbbing once per lap.

Changing `kLoopSeconds` **retunes the whole harmonic grid**; it is not a length
knob. `test/audio_assets_test.dart` holds all of this: the step across the join
must be no bigger than the largest step found inside the track, and the edges
must carry real content, so neither a chop nor a cheap fade passes.

---

## Project layout

```
lib/
  main.dart                  Bootstrap: orientation, controller, ads, audio
  app.dart                   MaterialApp, providers, localization delegates

  core/
    app_config.dart          Store + legal URLs, App Store id
    app_theme.dart           Colours, shapes, component themes
    balance.dart             EVERY tunable game number
    formatters.dart          Compact number + duration formatting

  data/
    accessory.dart           The wardrobe: what can be bought and worn
    creature_spec.dart       The parametric creature model (enums + spec)
    worlds.dart              The five meadows and their unlock rules
    creatures/*.dart         30 creature specs per meadow

  render/
    creature_painter.dart    Draws a CreatureSpec. The art engine.
    accessory_painter.dart   Draws what a creature is wearing
    shading.dart             The ramp/contour/shade vocabulary both share
    perch_painter.dart       The scenery a creature stands on
    meadow_backdrop.dart     Sky and ground behind the board
    merge_burst.dart         The spark ring thrown off by a merge

  models/
    game_state.dart          Save file: boards, tiles, currencies, settings

  services/
    ad_ids.dart              AdMob unit ids (live in release, test otherwise)
    ads_service.dart         Consent (UMP), ATT, banner/interstitial/rewarded
    audio_service.dart       Pooled SFX playback
    creature_names.dart      Localized creature names from JSON assets
    storage_service.dart     Debounced persistence

  state/
    game_controller.dart     Gameplay rules, income tick, progression

  ui/
    screens/                 Meadow, Collection, Shop, Meadows, Settings
    widgets/                 Board, creature view, HUD, banner slot, wardrobe
    dialogs.dart             Discovery, offline earnings, creature sheet
    world_labels.dart        Meadow id -> localized name
    accessory_labels.dart    Accessory -> localized name

assets/
  audio/                     Generated WAV cues, plus the looping music track
  i18n/                      Creature names, one JSON per language

tool/
  generate_icons.dart        Renders launcher icons from the game art
  generate_sfx.dart          Synthesises the sound effects
  generate_music.dart        Synthesises the seamless background loop
```

---

## Common tasks

### Add or edit a creature

Creature rosters live in `lib/data/creatures/<meadow>.dart`, ordered by tier.
Each entry is a `CreatureSpec`. To change how one looks, adjust its enums — no
painter changes needed for anything the existing part types already cover.

Then add its name to **all five** files in `assets/i18n/`, keyed by id
(`day_13`, `night_07`, …). A missing translation falls back to English and then
to the raw id, so it will never render blank — but it will look wrong.

Each meadow must have exactly 30 creatures with sequential tiers;
`test/game_rules_test.dart` enforces this.

### Add an accessory

Accessories are bought once with hearts and can then be worn by any discovered
friend; wearing is keyed to the species, so a hat survives merging away and
coming back. Adding one takes four edits:

1. A value on `AccessoryType` and an entry in `kAccessories`
   (`lib/data/accessory.dart`). The `rank` is a price band — cost and unlock
   threshold both come from `Balance`, nothing is priced by hand.
2. A `case` in `AccessoryArt.paintFront` and a framing rect in
   `_iconFocus` (`lib/render/accessory_painter.dart`). Anything that hangs
   behind the creature goes in `paintBack` instead.
3. A name key in all five `app_*.arb` files, plus the `switch` in
   `lib/ui/accessory_labels.dart`. `test/game_rules_test.dart` fails if an item
   is drawable but not for sale.
4. `flutter test test/accessory_sheet_preview.dart`, then look at the sheets —
   the art is anchored to landmarks that move a lot between body plans.

Accessory art is placed from an `AccessoryAnchor` — head top, face, collar
line — that `CreaturePainter` derives per body plan, so an item never needs to
know about body shapes. The collar in particular is *not* the top of the torso:
on a separate-headed creature that line runs across the muzzle.

### Review the artwork

```bash
flutter test test/creature_sheet_preview.dart
```

Writes a contact sheet per meadow to `build/art_preview/`. Do this after any
change to `creature_painter.dart` — a tweak to a shared part type affects every
creature that uses it, and the sheets are the only practical way to see that.

```bash
flutter test test/accessory_sheet_preview.dart
```

Writes two more sheets to the same place: every accessory as a shop swatch, and
a spread of body plans wearing each one.

```bash
flutter test test/merge_burst_preview.dart
```

Writes a filmstrip of the merge celebration, one row per meadow. The effect
lasts half a second on a device, which is far too quick to judge live — the
things to look for are the ring clearing before it starts to read as a
selection reticle, and the creature staying legible under the flash. Sparks
overlapping into the next frame are a quirk of the sheet, not a bug: the board
draws them unclipped so they can spill onto neighbouring perches.

### Regenerate the sound effects

```bash
dart run tool/generate_sfx.dart
```

Rewrites the six cues in `assets/audio/`. `test/audio_assets_test.dart` verifies
each result is valid 44.1 kHz mono PCM, audible, unclipped, and free of
onset/ending clicks.

### Regenerate the music

```bash
dart run tool/generate_music.dart
```

Rewrites `assets/audio/music_meadow.wav` and prints the size along with the step
across the loop join next to the worst step found inside the track. The first
number must not exceed the second — that is what "seamless" means here, and the
test asserts the same thing. Read the loop rules under
[Design notes](#all-sound-is-generated-in-code) before editing the piece.

### Regenerate the launcher icons

```bash
flutter test tool/generate_icons.dart
```

Writes every Android mipmap density (including the adaptive-icon foreground)
and every iOS `AppIcon.appiconset` slot. The icon is the Day Meadow fox cub
(`day_13`); change `kIconCreature` in the tool to use a different one.

### Add a UI string

Add the key to `lib/l10n/app_en.arb`, then to the other four `app_*.arb` files,
then:

```bash
flutter gen-l10n
```

Access it as `L.of(context).myKey`.

### Add a language

1. Add `lib/l10n/app_<code>.arb`.
2. Add `assets/i18n/creatures_<code>.json` with all 150 names.
3. Add the code to `CreatureNames.supported` in `lib/services/creature_names.dart`.
4. Add it to `kLanguageNames` in `lib/ui/screens/settings_screen.dart`.
5. Add it to `CFBundleLocalizations` in `ios/Runner/Info.plist`.
6. `flutter gen-l10n`.

### Tune the economy

Everything lives in `lib/core/balance.dart` — income and cost curves, basket
fill rate and tap value, offline cap and rate, boost duration, ad frequency
caps, board size.
Nothing else in the codebase hard-codes a balance number.

---

## Testing

```bash
flutter test
```

| File | Covers |
|---|---|
| `test/game_rules_test.dart` | Roster integrity, balance curves, wardrobe catalogue, board rules, merge-flag lifetime, save round-trip, number formatting |
| `test/widget_test.dart` | All 150 creatures paint without throwing; every accessory paints on every body plan |
| `test/audio_assets_test.dart` | WAV validity, loudness, clipping, click-free edges; music loop length, seam continuity, steady level |

`test/creature_sheet_preview.dart`, `test/accessory_sheet_preview.dart`,
`test/merge_burst_preview.dart` and `test/ui_preview.dart` are review tools, not
assertions — they write PNGs for a human to look at, and `flutter test` skips
them because they are not named `*_test.dart`.

---

## Shipping

### Ad units

The live AdMob ids are in the tree — they are public identifiers, not secrets.
Release builds pick them up with no extra flags:

```bash
flutter build appbundle --release
flutter build ipa --release --dart-define=APP_STORE_ID=1234567890
```

| | Android | iOS |
|---|---|---|
| App id | `...~1539772329` (`AndroidManifest.xml`) | `...~9295702361` (`Info.plist`) |
| Banner | `.../7913608986` | `.../2405347619` |
| Interstitial | `.../5886211445` | `.../7474625287` |
| Rewarded | `.../3718429286` | `.../1744515409` |

All under publisher `ca-app-pub-7855071425983459`; full values in
`lib/services/ad_ids.dart`.

Debug and profile builds serve Google's test units instead — never click a live
ad on your own build, it risks a policy strike. To point a debug build at a live
unit anyway, or to swap an id without editing source, `--dart-define` overrides
both in every build mode:

```bash
flutter run --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-XXXXX/YYYYY
```

Keys: `ADMOB_{BANNER,INTERSTITIAL,REWARDED}_{ANDROID,IOS}`.
`AdIds.usingTestUnits` reports whether a build is on test inventory.

### Pre-launch checklist

The app runs correctly today, but these are placeholders that **must** be
replaced before a public release:

- [ ] **Privacy policy and terms pages** must actually exist at the URLs in
      `lib/core/app_config.dart`. Both stores reject without a reachable
      privacy policy, and AdMob requires one.
- [ ] **App Store id** via `--dart-define=APP_STORE_ID=` so the in-app rate
      link resolves.
- [ ] **Android signing** — `android/app/build.gradle.kts` still uses the debug
      signing config for release builds. Wire up a real keystore.
- [ ] **Data safety / privacy nutrition labels** — declare advertising id
      collection on both stores.
- [ ] Confirm the AdMob account has the **GDPR and US state regulation consent
      messages** published, or the UMP form will never appear in the EEA/UK.

### Privacy and consent

`AdsService.initialize()` runs the UMP consent flow first, then the iOS ATT
prompt, then starts the ad SDK — and only requests ads if
`ConsentInformation.canRequestAds()` says it may. If consent is refused or the
SDK fails, the banner collapses to zero height and rewarded actions return
`false`; the game stays fully playable. Settings exposes a re-entry point to the
consent form wherever UMP reports one is legally required.

Ad content is capped at `MaxAdContentRating.g` to match the audience.

---

## Known gaps

- **iOS has not been built.** The project was developed on Windows; Android
  builds are verified, iOS compilation is not. Build it on a Mac before
  trusting the iOS half.
- **`test/ui_preview.dart` renders text as solid blocks.** Widget tests have no
  real font, so the shots are good for layout and artwork and useless for
  copy. Check string length on a device.
- **No IAP.** Monetisation is ads-only. There is no remove-ads purchase, which
  is unusual for the genre and worth considering.
- **`audioplayers` is pinned to `^6.7.1`.** 6.8.x requires a newer Flutter SDK
  than this project targets; bump both together.
- **Saves are local only.** No cloud sync, so reinstalling loses progress.
