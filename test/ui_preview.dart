// Development-only UI proof shots.
//
// Run with:  flutter test test/ui_preview.dart
// Writes PNGs of the real screens so layout can be reviewed without a device.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/core/app_theme.dart';
import 'package:mergelings/data/accessory.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/l10n/app_localizations.dart';
import 'package:mergelings/services/ads_service.dart';
import 'package:mergelings/state/game_controller.dart';
import 'package:mergelings/ui/screens/collection_screen.dart';
import 'package:mergelings/ui/screens/meadow_screen.dart';
import 'package:mergelings/ui/screens/meadows_screen.dart';
import 'package:mergelings/ui/screens/shop_screen.dart';
import 'package:mergelings/ui/widgets/creature_view.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kOutDir = 'build/ui_preview';

void main() {
  late GameController game;
  late AdsService ads;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    game = await GameController.boot();
    // There is no audio plugin behind a widget test, and the first cue would
    // fail the run on a platform-channel exception.
    game.setSound(false);
    ads = AdsService();
  });

  tearDown(() => game.dispose());

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget screen, {
    Locale locale = const Locale('en'),
    Future<void> Function(WidgetTester tester)? interact,
  }) async {
    tester.view
      ..physicalSize = const Size(1080, 2100)
      ..devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final GlobalKey boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<GameController>.value(value: game),
          ChangeNotifierProvider<AdsService>.value(value: ads),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: locale,
          supportedLocales: L.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<Object>>[
            L.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: screen,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // Anything that has to be opened — a dialog, a sheet — is opened here
    // rather than before the shot: pumping the tree again would lose the route.
    if (interact != null) {
      await interact(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    final RenderRepaintBoundary boundary =
        tester.renderObject(find.byKey(boundaryKey));
    // Rasterising and writing the file are real async work; awaited straight
    // in the test body they would sit forever behind the fake clock.
    await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage();
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Directory dir = Directory(kOutDir);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('$kOutDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  testWidgets('meadow', (WidgetTester tester) async {
    // A board mid-session reads far more usefully than an empty one.
    for (int i = 0; i < 9; i++) {
      game.tapBasket();
    }
    game.clearDiscovery();
    await shoot(tester, 'meadow', const Scaffold(body: MeadowScreen()));
  });

  /// A player far enough in to see the wardrobe: hearts to spend, a collection
  /// big enough to have unlocked the bands, and a couple of items already
  /// bought so both card states show up.
  void dressUp() {
    game.state.hearts = 4000000;
    for (int tier = 1; tier <= 30; tier++) {
      game.state.discovered.add('day_${tier.toString().padLeft(2, '0')}');
    }
    game.buyAccessory(kAccessories.first);
    game.buyAccessory(kAccessories[4]);
    game.wearAccessory(kWorlds.first.creatureAt(1), kAccessories[4].type);
  }

  testWidgets('shop', (WidgetTester tester) async {
    dressUp();
    await shoot(tester, 'shop', const ShopScreen());
  });

  testWidgets('collection', (WidgetTester tester) async {
    game.tapBasket();
    game.clearDiscovery();
    await shoot(tester, 'collection', const CollectionScreen());
  });

  testWidgets('collection detail', (WidgetTester tester) async {
    dressUp();
    await shoot(
      tester,
      'collection_detail',
      const CollectionScreen(),
      interact: (WidgetTester tester) =>
          tester.tap(find.byType(CreatureView).first),
    );
  });

  testWidgets('meadows', (WidgetTester tester) async {
    await shoot(
      tester,
      'meadows',
      MeadowsScreen(onEnterMeadow: () {}),
    );
  });

  testWidgets('meadow_de', (WidgetTester tester) async {
    game.tapBasket();
    game.clearDiscovery();
    await shoot(
      tester,
      'meadow_de',
      const Scaffold(body: MeadowScreen()),
      locale: const Locale('de'),
    );
  });
}
