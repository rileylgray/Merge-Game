import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'services/ads_service.dart';
import 'state/game_controller.dart';
import 'ui/screens/home_shell.dart';

class MergelingsApp extends StatelessWidget {
  const MergelingsApp({
    super.key,
    required this.game,
    required this.ads,
  });

  final GameController game;
  final AdsService ads;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<GameController>.value(value: game),
        ChangeNotifierProvider<AdsService>.value(value: ads),
      ],
      // Selector, not Consumer: the language is the only thing up here that
      // can change, and a Consumer rebuilt the entire MaterialApp — theme,
      // localisations, navigator and all — on every notification from the
      // controller.
      child: Selector<GameController, String?>(
        selector: (_, GameController game) => game.state.localeCode,
        builder: (BuildContext context, String? code, Widget? child) {
          return MaterialApp(
            title: 'Mergelings',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: code == null ? null : Locale(code),
            supportedLocales: L.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              L.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
