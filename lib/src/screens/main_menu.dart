import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/menu_button.dart';

import '../tools.dart';

class MainMenu extends StatelessWidget with NoNetworkModal {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(context.loc().mainTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuButton(
                  onPressed: () {
                    if (SettingsController().playIsImpossible) {
                      dlgNoNetwork(context);
                    } else {
                      RouteBuilder.gotoGameVeryStart(context);
                    }
                  },
                  text: context.loc().mainStart),
              MenuButton(
                  color: Colors.blue,
                  onPressed: () => RouteBuilder.gotoSettings(context),
                  text: context.loc().mainSettings),
              kIsWeb
                  ? Container()
                  : MenuButton(
                      color: Colors.red,
                      onPressed: () {
                        if (Platform.isAndroid || Platform.isIOS) {
                          SystemNavigator.pop();
                        } else {
                          exit(0);
                        }
                      },
                      text: context.loc().mainExit),
            ],
          ),
        ),
      ),
    );
  }
}
