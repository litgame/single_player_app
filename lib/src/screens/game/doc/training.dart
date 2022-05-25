import 'package:flutter/material.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/documentation_screen.dart';

import '../../../tools.dart';

class DocTrainingScreen extends StatelessWidget {
  const DocTrainingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(context.loc().gameTitleDocTraining)),
      body: DocumentationScreen(
          data: context.loc().docTrainingScreen,
          onOk: () {
            RouteBuilder.gotoTraining(context);
          }),
    );
  }
}
