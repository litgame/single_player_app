import 'package:flutter/material.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/documentation_screen.dart';

import '../../../tools.dart';

class DocGameScreen extends StatelessWidget {
  const DocGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(context.loc().gameTitleDocGame)),
      body: DocumentationScreen(
          data: context.loc().docGameScreen,
          onOk: () {
            RouteBuilder.gotoGameProcess(context);
          }),
    );
  }
}
