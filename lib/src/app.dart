import 'package:catcher/catcher.dart';
import 'package:catcher/core/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:single_player_app/src/services/route_builder.dart';

import 'screens/settings/settings_controller.dart';
import 'tools.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController();
    return AnimatedBuilder(
      animation: settings,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
            restorationScopeId: 'app',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
            ],
            onGenerateTitle: (BuildContext context) => context.loc().appTitle,
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: settings.themeMode,
            navigatorKey: Catcher.navigatorKey,
            onGenerateRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) =>
                      RouteBuilder.build(routeSettings.name, context));
            },
            onUnknownRoute: (RouteSettings routeSettings) =>
                MaterialPageRoute<void>(
                    settings: routeSettings,
                    builder: (_) => RouteBuilder.notFoundRoute(context)));
      },
    );
  }
}
