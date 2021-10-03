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
          data:
              '__Суть и задача игры__ - составить вместе с друзьями произвольную историю '
              'на определённую тему. И, конечно, получить удовольствие и от процесса и от '
              'результата :-) \r\n\r\n'
              '__Правила игры:__\r\n'
              ' - Игроки ходят по очереди. Каждый игрок в свой ход тянет карту из одной из трёх '
              'колод на выбор и рассказывает свою часть истории, руководствуясь той картой, '
              'которая ему выпала. \r\n\r\n'
              ' - Во время хода игрока никто не имеет права его поправлять или перебивать, он '
              'полностью свободен в трактовке смысла карты и составлении своей части истории, '
              'хотя и должен опираться на здравый смысл, рассказанный ранее сюжет и общие '
              'договорённости.\r\n\r\n'
              ' - Перед началом игры рекомендуется совместно решить, к какому жанру, стилю и '
              'вселенной будет относиться повествование.\r\n\r\n'
              '\r\n'
              '__Виды карт.__ Карты в игре есть трёх типов:\r\n'
              ' - Место - предполагает, что действие сюжета должно быть перенесено в '
              'указанное на карте место (в прямом или переносном смысле)\r\n'
              ' - Персонаж - вытянувший эту карту игрок должен ввести в повествование персонажа '
              '(в прямом или переносном смысле), указанного на карте. \r\n'
              ' - Общая - эти карты задают тему для всех остальных событий/явлений, которые '
              'должны произойти в игровом мире в ход вытянувшего их игрока. \r\n'
              '\r\n'
              'НО не относитесь к этому чересчур серьёзно! Помните - это всего лишь игра ;-)',
          onOk: () {
            SettingsController().updateShowDocAllScreen(false);
            RouteBuilder.gotoDocTraining(context);
          }),
    );
  }
}
