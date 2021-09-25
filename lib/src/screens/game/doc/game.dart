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
          data: 'Начинаем сам игровой процесс!\r\n'
              'Теперь каждому игроку нужно будет в свой ход выбрать карту из'
              'одной из трёх колод. Почле чего рассказать своб часть истории, '
              'ориентируясь на то, что указано на карте. \r\n'
              'По завершении истории нужно нажать зелёную кнопку в верхнем правом углу '
              'и передать телефон следующему игроку. \r\n\r\n'
              'Игромастер начинает первым, и ему в свой первый ход будут показаны '
              'сразу три карты, из которых нужно собрать завязку истории, после '
              'чего передать ход следующему игроку. ',
          onOk: () {
            RouteBuilder.gotoGameProcess(context);
          }),
    );
  }
}
