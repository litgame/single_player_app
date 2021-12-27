import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:single_player_app/src/screens/game/magic/ui/ui_type.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/tools.dart';

class UITypeKeyword extends UITypeBase {
  UITypeKeyword(MagicType type) : super(type);

  var fireAfterTurns = 1;
  var repeatCount = 3;
  var description = '';

  @override
  List<Widget> buildCreateUI(BuildContext context) => [
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Text(
            context.loc().magicKeywordDescription,
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
        Text(context.loc().magicKeywordText),
        TextField(
            maxLines: null,
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              description = value;
            }),
        Text(context.loc().magicKeywordRepeats),
        Row(
          children: [
            SizedBox(
              width: 200,
              child: SpinBox(
                min: 1,
                max: 30,
                value: repeatCount.toDouble(),
                onChanged: (value) {
                  repeatCount = value.toInt();
                },
              ),
            ),
          ],
        ),
      ];

  @override
  MagicItem getMagicItem() =>
      MagicItem.keyword(description, fireAfterTurns, repeatCount);

  @override
  List<Widget> buildViewUI(BuildContext context) => [
        ViewUIRow(Text(
          context.loc().magicKeywordViewDescription(repeatCount, description),
        )),
      ];

  @override
  void fillMagicData(MagicItem magicItem) {
    description = magicItem.description;
    repeatCount = magicItem.repeatCount;
  }
}
