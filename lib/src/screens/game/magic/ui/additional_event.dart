import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:single_player_app/src/screens/game/magic/ui/ui_type.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/tools.dart';

class UITypeAdditionalEvent extends UITypeBase {
  var fireAfterTurns = 1;

  @override
  List<Widget> build(BuildContext context) => [
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Text(
            context.loc().magicAdditionalEventDescription,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        Text(context.loc().magicModalTurns),
        Row(
          children: [
            SizedBox(
              width: 200,
              child: SpinBox(
                min: 1,
                value: fireAfterTurns.toDouble(),
                onChanged: (value) {
                  fireAfterTurns = value.toInt();
                },
              ),
            ),
          ],
        ),
      ];

  @override
  MagicItem getMagicItem() => MagicItem.additionalEvent(fireAfterTurns);

  @override
  String title(BuildContext context) => context.loc().magicAdditionalEventTitle;
}
