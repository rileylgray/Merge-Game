// Captures the raw app screens used for the App Store and Play Store listing
// images into build/store_raw/*.png. The framing, headlines and export sizes
// are added afterwards by tool/store_screenshots/compose.mjs.
//
// These are the real screens — the shell with its navigation bar, the meadow,
// the collection, the discovery fanfare — pumped at an iPhone-sized window and
// again at an iPad-sized one (into build/store_raw/ipad/), each with its safe
// area, so the listing never shows anything the app does not. No ad appears:
// the banner slot keeps zero height until the ad SDK serves one, and nothing
// starts the SDK here.
//
// Run with:
//   flutter test test/store_screenshot_capture.dart
//
// Like the other review tools here it is not named *_test.dart, so a plain
// `flutter test` leaves it out.
//
// The test font draws every glyph as a box, so Roboto and the Material icon
// font are loaded from the Flutter SDK's cache. Without them this does nothing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/models/game_state.dart';
import 'package:mergelings/services/ads_service.dart';
import 'package:mergelings/state/game_controller.dart';
import 'package:mergelings/ui/screens/collection_screen.dart';
import 'package:mergelings/ui/screens/home_shell.dart';
import 'package:mergelings/ui/widgets/creature_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/store_capture.dart';

final GlobalKey _boundary = GlobalKey();

/// How far into each meadow the player has got.
const Map<String, int> _found = <String, int>{
  'day': 26,
  'night': 24,
  'water': 24,
  'mythical': 29,
  'prehistoric': 26,
};

/// Each meadow's board, six rows of six, read left to right. 0 is an empty
/// cell. Every friend shown has been found, and a few pairs sit side by side
/// waiting to be merged, the way a board looks mid-session.
const Map<String, List<int>> _boards = <String, List<int>>{
  'day': <int>[
    13, 13, 7, 0, 10, 12, //
    8, 14, 11, 9, 22, 5,
    3, 1, 20, 15, 6, 6,
    2, 9, 0, 17, 19, 4,
    21, 16, 18, 24, 11, 1,
    12, 3, 0, 14, 7, 25,
  ],
  'night': <int>[
    8, 10, 5, 0, 12, 13, //
    9, 6, 15, 11, 2, 22,
    1, 17, 14, 18, 3, 7,
    19, 0, 4, 16, 10, 8,
    2, 12, 20, 6, 23, 13,
    21, 5, 9, 0, 11, 24,
  ],
  'water': <int>[
    8, 9, 5, 0, 11, 7, //
    12, 6, 10, 17, 1, 3,
    13, 18, 0, 16, 14, 4,
    2, 19, 15, 9, 22, 11,
    6, 20, 3, 10, 5, 0,
    24, 8, 21, 12, 23, 9,
  ],
  'mythical': <int>[
    15, 7, 3, 0, 9, 4, //
    8, 16, 12, 24, 14, 0,
    5, 10, 18, 2, 13, 6,
    11, 21, 17, 15, 7, 3,
    29, 9, 14, 0, 8, 12,
    2, 27, 20, 22, 25, 10,
  ],
  'prehistoric': <int>[
    11, 6, 3, 0, 7, 9, //
    1, 12, 10, 14, 2, 20,
    8, 15, 4, 16, 13, 5,
    2, 18, 11, 9, 6, 10,
    7, 14, 25, 0, 12, 3,
    26, 21, 1, 24, 17, 0,
  ],
};

/// A few favourites dressed up, so the wardrobe shows on the boards too.
const Map<String, String> _worn = <String, String>{
  'day_07': 'flowerCrown',
  'day_13': 'topHat',
  'day_14': 'partyHat',
  'day_25': 'crown',
  'night_10': 'bowTie',
  'water_17': 'scarf',
  'mythical_29': 'crown',
  'mythical_24': 'flowerCrown',
  'prehistoric_26': 'partyHat',
};

/// A player well into the game: every meadow open, a purse worth showing, a
/// wardrobe bought, and the tutorial long behind them.
void _stage(GameController game) {
  final GameState s = game.state
    ..tutorialSeen = true
    ..hearts = 1284500
    ..gems = 86
    ..basketFill = .62;
  _found.forEach((String world, int count) {
    for (int tier = 1; tier <= count; tier++) {
      s.discovered.add('${world}_${tier.toString().padLeft(2, '0')}');
    }
  });
  int id = 1000;
  _boards.forEach((String world, List<int> tiers) {
    final BoardState board = s.board(world)..rows = 6;
    for (int i = 0; i < tiers.length; i++) {
      board.set(i, tiers[i] == 0 ? null : BoardTile(id: id++, tier: tiers[i]));
    }
  });
  s.ownedAccessories.addAll(<String>[
    'flowerCrown',
    'bowTie',
    'partyHat',
    'scarf',
    'topHat',
    'sunglasses',
    'crown',
  ]);
  s.wornAccessories.addAll(_worn);
}

void main() {
  final String? fonts = storeFontDir;
  late GameController game;
  late AdsService ads;

  setUpAll(() async {
    if (fonts != null) await loadStoreFonts(fonts);
    // The shell keeps the Settings tab alive, and it asks the platform for the
    // version on its way in.
    PackageInfo.setMockInitialValues(
      appName: 'Mergelings',
      packageName: 'com.realgamesrealfun.mergelings',
      version: '2.0.1',
      buildNumber: '15',
      buildSignature: '',
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    game = await GameController.boot();
    // There is no audio plugin behind a widget test, and the first cue would
    // fail the run on a platform-channel exception.
    game.setSound(false);
    game.setMusic(false);
    ads = AdsService();
    _stage(game);
  });

  tearDown(() => game.dispose());

  Future<void> open(WidgetTester tester, StoreDevice device) async {
    device.applyTo(tester);
    await tester.pumpWidget(
      RepaintBoundary(
        key: _boundary,
        child: storeApp(game, ads, const HomeShell()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> shoot(WidgetTester tester, StoreDevice device, String name) =>
      saveStoreCapture(tester, device, _boundary, name);

  /// Unmounts the app and drains its timers so nothing leaks into the next.
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  final bool skip = fonts == null;

  for (final StoreDevice device in storeDevices) {
    group(device.name, () {
      for (final World world in kWorlds) {
        testWidgets('meadow ${world.id}', skip: skip, (
          WidgetTester tester,
        ) async {
          game.state.activeWorldId = world.id;
          await open(tester, device);
          await shoot(tester, device, 'meadow_${world.id}');
          await finish(tester);
        });
      }

      testWidgets('discovery', skip: skip, (WidgetTester tester) async {
        // The elephant, met for the first time on a busy Day Meadow board.
        game.state.activeWorldId = 'day';
        game.pendingDiscovery = DiscoveryEvent(
          worldById('day').creatureAt(27),
          12,
        );
        await open(tester, device);
        await settle(tester);
        await shoot(tester, device, 'discovery');
        await finish(tester);
      });

      testWidgets('collection', skip: skip, (WidgetTester tester) async {
        await open(tester, device);
        await tester.tap(find.byIcon(Icons.menu_book_outlined));
        await settle(tester);
        // Scrolled to the end of the meadow, where the last few friends are
        // still waiting to be found.
        await tester.drag(
          find.descendant(
            of: find.byType(CollectionScreen),
            matching: find.byType(Scrollable),
          ).first,
          const Offset(0, -3000),
        );
        await settle(tester);
        await shoot(tester, device, 'collection');
        await finish(tester);
      });

      testWidgets('dress up', skip: skip, (WidgetTester tester) async {
        await open(tester, device);
        await tester.tap(find.byIcon(Icons.menu_book_outlined));
        await settle(tester);
        // The bunny in her flower crown, with the wardrobe beneath her.
        await tester.tap(
          find.descendant(
            of: find.byType(CollectionScreen),
            matching: find.byType(CreatureView),
          ).at(6),
        );
        await settle(tester);
        await shoot(tester, device, 'dress_up');
        await finish(tester);
      });
    });
  }
}
