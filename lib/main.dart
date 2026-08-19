import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/ads_service.dart';
import 'state/game_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only: the board is laid out for a single thumb.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  final GameController game = await GameController.boot();
  final AdsService ads = AdsService();

  // A full-screen ad brings its own soundtrack; the meadow's steps aside for
  // as long as one is up.
  ads.onFullScreenChanged =
      (bool showing) => game.duckMusicForAd(ducked: showing);

  // Consent, the ad SDK and the audio all start in the background: the player
  // reaches the meadow immediately and each slots in once ready.
  unawaited(ads.initialize());
  unawaited(game.warmUpAudio());
  unawaited(game.startMusic());

  runApp(MergelingsApp(game: game, ads: ads));
}
