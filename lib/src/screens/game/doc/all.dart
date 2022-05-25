import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/documentation_screen.dart';

import '../../../tools.dart';

class DocAllScreen extends StatelessWidget {
  const DocAllScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(context.loc().gameTitleDocAll)),
      body: DocumentationScreen(
          data: context.loc().docAllScreen,
          onOk: () {
            SettingsController().updateShowDocAllScreen(false);
            RouteBuilder.gotoDocTraining(context);
          }),
    );
  }
}
