// Shared set-up for the store screenshot captures: the devices the screens are
// pumped at, the real fonts, the app as main.dart builds it, and saving a
// render to PNG.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/core/app_theme.dart';
import 'package:mergelings/l10n/app_localizations.dart';
import 'package:mergelings/services/ads_service.dart';
import 'package:mergelings/state/game_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// A device the listing screens are captured at: its window in logical pixels,
/// pixel ratio, and the safe area its status bar and home indicator take.
class StoreDevice {
  const StoreDevice(
    this.name, {
    required this.size,
    required this.dpr,
    required this.safeTop,
    required this.safeBottom,
    required this.rawDir,
  });

  final String name;
  final Size size;
  final double dpr;
  final double safeTop;
  final double safeBottom;

  /// Where this device's captures are saved.
  final String rawDir;

  /// Sizes the test window to this device, with its safe area, and asks for
  /// reduced motion — which the creatures honour by holding still with their
  /// eyes open, so no capture ever catches one mid-blink.
  void applyTo(WidgetTester tester) {
    tester.view.physicalSize = size * dpr;
    tester.view.devicePixelRatio = dpr;
    tester.view.padding = FakeViewPadding(
      top: safeTop * dpr,
      bottom: safeBottom * dpr,
    );
    tester.view.viewPadding = tester.view.padding;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
}

/// iPhone 15/16 Pro, for the App Store phone slides and Google Play.
const StoreDevice storePhone = StoreDevice(
  'phone',
  size: Size(393, 852),
  dpr: 3,
  safeTop: 59,
  safeBottom: 34,
  rawDir: 'build/store_raw',
);

/// 13" iPad Pro in portrait, for the App Store iPad slides.
const StoreDevice storeIpad = StoreDevice(
  'ipad',
  size: Size(1032, 1376),
  dpr: 2,
  safeTop: 24,
  safeBottom: 20,
  rawDir: 'build/store_raw/ipad',
);

const List<StoreDevice> storeDevices = <StoreDevice>[storePhone, storeIpad];

/// The Flutter SDK's copy of Roboto and the Material icons, or null when the
/// SDK can't be found — in which case the captures skip themselves, since the
/// test font would draw every glyph as a box.
String? get storeFontDir {
  final String? root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return null;
  final Directory dir = Directory('$root/bin/cache/artifacts/material_fonts');
  return dir.existsSync() ? dir.path : null;
}

Future<void> loadStoreFonts(String dir) async {
  Future<ByteData> read(String path) async =>
      ByteData.sublistView(File(path).readAsBytesSync());

  final FontLoader roboto = FontLoader('Roboto');
  for (final String weight in <String>[
    'Light',
    'Regular',
    'Medium',
    'Bold',
    'Black',
  ]) {
    roboto.addFont(read('$dir/Roboto-$weight.ttf'));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('$dir/MaterialIcons-Regular.otf'))).load();
}

/// The app as main.dart builds it — same providers, theme and localisations —
/// but around [home] rather than always the shell, so a capture can open on
/// any screen. Ads never show: the banner keeps zero height until the ad SDK
/// serves one, and nothing starts the SDK here.
Widget storeApp(GameController game, AdsService ads, Widget home) =>
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<GameController>.value(value: game),
        ChangeNotifierProvider<AdsService>.value(value: ads),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: storeTheme(),
        locale: const Locale('en'),
        supportedLocales: L.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          L.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );

/// The app's theme with its stand-alone text styles pinned to Roboto.
///
/// The app-bar title and button labels are complete styles of their own rather
/// than tweaks merged onto the text theme, so they name no font. On a phone
/// that means the system font — Roboto on Android — but in a test it means the
/// test font, which draws every glyph as a box. Naming Roboto here gives the
/// captures what an Android phone would draw.
ThemeData storeTheme() {
  final ThemeData base = AppTheme.light();
  TextStyle? roboto(TextStyle? style) => style?.copyWith(fontFamily: 'Roboto');
  ButtonStyle? pinned(ButtonStyle? style) => style?.copyWith(
    textStyle: WidgetStatePropertyAll<TextStyle?>(
      roboto(style.textStyle?.resolve(<WidgetState>{})),
    ),
  );
  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: roboto(base.appBarTheme.titleTextStyle),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: pinned(base.filledButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: pinned(base.outlinedButtonTheme.style),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      contentTextStyle: roboto(base.snackBarTheme.contentTextStyle),
    ),
  );
}

/// Saves what [boundary] holds to [StoreDevice.rawDir]/[name].png, at the
/// device's pixel ratio.
Future<void> saveStoreCapture(
  WidgetTester tester,
  StoreDevice device,
  GlobalKey boundary,
  String name,
) async {
  final RenderRepaintBoundary box =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  // toImage hands back a real Future, which never completes inside the fake
  // async zone a widget test runs in.
  final ByteData? bytes = await tester.runAsync<ByteData?>(() async {
    final ui.Image image = await box.toImage(pixelRatio: device.dpr);
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    return data;
  });
  final File out = File('${device.rawDir}/$name.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(bytes!.buffer.asUint8List());
}
