import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/ui/ui_type.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/tools.dart';
import 'package:single_player_app/src/ui/app_bar_button.dart';

class MagicNewScreen extends StatelessWidget {
  MagicNewScreen({Key? key, required MagicType chosenMagic})
      : uiGenerator = uiTypeFactory(chosenMagic),
        super(key: key);

  final UITypeBase uiGenerator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            AppBarButton(
              onPressed: () {
                _onSave(context);
              },
              text: context.loc().magicModalSave,
            )
          ],
          backgroundColor: Colors.purple,
          title: Text(context.loc().magicModalTitle +
              ' ' +
              uiGenerator.title(context))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: uiGenerator.build(context),
      ),
    );
  }

  void _onSave(BuildContext context) {
    try {
      final magicItem = uiGenerator.getMagicItem();
      Navigator.of(context).pop(magicItem);
    } on ArgumentError catch (error) {
      var errorTranslation = context.loc().magicAlertUnknown;
      switch (error.name) {
        case 'description':
          final magicType = error.message;
          if (magicType is MagicType) {
            switch (magicType) {
              case MagicType.marionette:
                errorTranslation =
                    context.loc().magicAlertDescriptionMarionette;
                break;
              case MagicType.eurythmics:
                errorTranslation =
                    context.loc().magicAlertDescriptionEurythmics;
                break;
              case MagicType.keyword:
                errorTranslation = context.loc().magicAlertDescriptionKeyword;
                break;
              case MagicType.additionalEvent:
                break;
              case MagicType.cancelMagic:
                break;
            }
          }
          break;
        case 'fireAfterTurns':
          errorTranslation = context.loc().magicAlertTurn;
          break;
      }
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(context.loc().gameOkButton),
                  )
                ],
                title: Text(context.loc().magicAlertTitle),
                content: Text(errorTranslation),
              ));
    }
  }
}
