import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:single_player_app/src/screens/game/magic/ui/ui_type.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/tools.dart';

class UITypeMarionette extends UITypeBase {
  var fireAfterTurns = 1;
  var description = '';

  @override
  List<Widget> build(BuildContext context) => [
        Text(context.loc().magicModalTurns),
        SpinBox(
          min: 1,
          value: fireAfterTurns.toDouble(),
          onChanged: (value) {
            fireAfterTurns = value.toInt();
          },
        ),
        Text(context.loc().magicMarionetteText),
        TextField(
            maxLines: null,
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              description = value;
            })
      ];

  @override
  MagicItem getMagicItem() => MagicItem.marionette(description, fireAfterTurns);
}
