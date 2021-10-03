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
          data: 'Небольшая разминка!\r\n'
              'Сейчас каждому из игроков будет выдаваться случайная карта из колоды, '
              'и нужно будет по ней рассказать что-то, что связано с миром/темой, '
              'на которую вы собираетесь играть.\r\n'
              'Это позволит немного разогреть мозги, вспомнить забытые факты и "прокачать" '
              'менее подготовленных к игре товарищей.\r\n'
              'После того как расскажете свои ассоциации по карте - '
              'смахните её и передайте телефон следующему игроку\r\n\r\n'
              'Для завершения разминки нажмите зелёную кнопку в правом верхнем углу.',
          onOk: () {
            RouteBuilder.gotoTraining(context);
          }),
    );
  }
}
