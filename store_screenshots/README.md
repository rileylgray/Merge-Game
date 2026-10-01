# Store screenshots

Listing images for the App Store and Google Play. Each one is a real app
screen inside a device frame, with a headline. No ads are shown.

| Folder            | Size        | Use                                   |
|-------------------|-------------|---------------------------------------|
| `app_store/`      | 1290 × 2796 | iPhone 6.9" / 6.7" display            |
| `app_store_ipad/` | 2064 × 2752 | iPad 13" display                      |
| `play_store/`     | 1080 × 1920 | Phone screenshots (9:16)              |

The iPad slides show the app as it lays out on a 13" iPad Pro rather than a
stretched phone screen, because the captures run a second time at iPad size.

1. `01_merge`: Merge adorable friends (Day Meadow board)
2. `02_discover`: Discover new friends (the Elephant's discovery fanfare)
3. `03_meadows`: Explore magical meadows (Night and Sea Meadow boards)
4. `04_collection`: Fill your collection (end of the Day Meadow page). This
   slide is phone only. On a 13" iPad a whole meadow fits in four rows and
   leaves half the screen bare, and slide 5 already shows the grid.
5. `05_dress_up`: Dress them up (the Bunny's wardrobe sheet)
6. `06_legends`: Dragons, dinos & more (Myth and Dino Meadow boards)

The captures play a player who is well into the game:

- 129 of the 150 friends found.
- Every meadow open, with a full board in each.
- A few favourites dressed up.

Animations are turned off for the captures, so no creature is caught
mid-blink.

## Regenerating

```sh
flutter test test/store_screenshot_capture.dart   # raw screens -> build/store_raw/
NODE_PATH=$(npm root -g) node tool/store_screenshots/compose.mjs [store dir...]
```

Pass store folders (e.g. `app_store_ipad`) to build just those. All three are
built by default.

The capture loads Roboto and the Material icons from the Flutter SDK's cache,
and skips itself if it can't find them. `compose.mjs` needs Playwright with a
Chromium it can find.

All of this lives in the `slides` list at the top of
`tool/store_screenshots/compose.mjs`:

- The headlines and colours.
- Which screens each slide uses.
- Which devices a slide is left out for.

The screens themselves are set up in `test/store_screenshot_capture.dart`.
Fonts are Poppins and Inter, under the SIL Open Font License (see
`tool/store_screenshots/fonts/`).
