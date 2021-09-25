import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/menu_button.dart';

import '../tools.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc().mainTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuButton(
                  onPressed: () => RouteBuilder.gotoGameVeryStart(context),
                  text: context.loc().mainStart),
              MenuButton(
                  color: Colors.blue,
                  onPressed: () => RouteBuilder.gotoSettings(context),
                  text: context.loc().mainSettings),
              MenuButton(
                  color: Colors.red,
                  onPressed: () => SystemNavigator.pop(),
                  text: context.loc().mainExit),
            ],
          ),
        ),
      ),
    );
  }
}
