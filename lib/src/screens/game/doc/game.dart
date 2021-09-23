import 'package:flutter/material.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/documentation_screen.dart';

import '../../../tools.dart';

class DocGameScreen extends StatelessWidget {
  const DocGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.loc().gameTitleDocGame)),
      body: DocumentationScreen(
          data: 'Суть и задача игры__ - составить...\r\n'
              '123123123',
          onOk: () {
            RouteBuilder.gotoGameProcess(context);
          }),
    );
  }
}
