import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/doc/all.dart';
import 'package:single_player_app/src/screens/game/doc/game.dart';
import 'package:single_player_app/src/screens/game/doc/training.dart';
import 'package:single_player_app/src/screens/game/game/game_screen.dart';
import 'package:single_player_app/src/screens/game/magic_settings.dart';
import 'package:single_player_app/src/screens/game/training/training_screen.dart';
import 'package:single_player_app/src/screens/main_menu.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/screens/settings/settings_view.dart';
import 'package:single_player_app/src/ui/documentation_screen.dart';

import '../tools.dart';

typedef RouteItem = Widget Function(BuildContext context);

class RouteBuilder {
  static final _routeMap = <String, RouteItem>{
    '/': (ctx) => const MainMenu(),
    '/main': (ctx) => const MainMenu(),
    '/settings': (ctx) => const SettingsView(),
    '/doc': (ctx) => const DocAllScreen(),
    '/game/training/doc': (ctx) => const DocTrainingScreen(),
    '/game/training/process': (ctx) => TrainingScreen(),
    '/game/training/magic-settings': (ctx) => const MagicSettings(),
    '/game/game/': (ctx) => _gameRoute(),
    '/game/game/doc': (ctx) => const DocGameScreen(),
    '/game/game/process': (ctx) => const GameScreen(),
  };

  static Widget build(String? routeName, BuildContext context) {
    final routeFunc = _routeMap[routeName];
    if (routeFunc == null) {
      return notFoundRoute(context);
    }

    return routeFunc(context);
  }

  static Widget notFoundRoute(BuildContext context) => Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.purple,
            title: Text(context.loc().pageNotFoundTitle)),
        body: DocumentationScreen(
            data: 'Ой!!\r\n'
                'Где это мы??! \r\n'
                'Нет такого места, вернись откуда пришел... \r\n',
            onOk: () {
              RouteBuilder.gotoMainMenu(context, cleanMissing: true);
            }),
      );

  static Widget _gameRoute() {
    if (SettingsController().showDocGameScreen) {
      return const DocGameScreen();
    }

    return const GameScreen();
  }

  static gotoMainMenu(BuildContext context,
      {bool cleanMissing = false, bool reset = false}) {
    if (cleanMissing) {
      Navigator.of(context).restorablePushNamedAndRemoveUntil('/main',
          (Route<dynamic> route) => _routeMap.containsKey(route.settings.name));
    } else if (reset) {
      Navigator.of(context).restorablePushNamedAndRemoveUntil(
          '/main', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).restorablePushNamed('/main');
    }
  }

  static gotoSettings(BuildContext context) {
    Navigator.of(context).restorablePushNamed('/settings');
  }

  static gotoGameVeryStart(BuildContext context) {
    if (SettingsController().showDocAllScreen) {
      Navigator.of(context).restorablePushNamed('/doc');
    } else if (SettingsController().showDocTrainingScreen) {
      Navigator.of(context).restorablePushNamed('/game/training/doc');
    } else if (SettingsController().withMagic) {
      Navigator.of(context)
          .restorablePushNamed('/game/training/magic-settings');
    } else {
      Navigator.of(context).restorablePushNamed('/game/training/process');
    }
  }

  static gotoDocTraining(BuildContext context) {
    Navigator.of(context).restorablePushNamed('/game/training/doc');
  }

  static gotoTraining(BuildContext context) {
    if (SettingsController().withMagic) {
      Navigator.of(context)
          .restorablePushNamed('/game/training/magic-settings');
    } else {
      Navigator.of(context).restorablePushNamed('/game/training/process');
    }
  }

  static gotoTestFinishGameStart(BuildContext context) {
    if (SettingsController().showDocGameScreen) {
      Navigator.of(context).restorablePushNamed('/game/game/doc');
    } else {
      Navigator.of(context).restorablePushNamedAndRemoveUntil(
          '/game/game/', (Route<dynamic> route) => false);
    }
  }

  static gotoGameProcess(BuildContext context) {
    Navigator.of(context).restorablePushNamedAndRemoveUntil(
        '/game/game/process', (Route<dynamic> route) => false);
  }
}
