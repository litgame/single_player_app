import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:single_player_app/src/screens/game/magic/ui/ui_type.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';
import 'package:single_player_app/src/tools.dart';
import 'package:single_player_app/src/ui/app_bar_button.dart';

class MagicNewScreen extends StatelessWidget with LayoutOrientation {
  MagicNewScreen(
      {Key? key, required MagicType chosenMagic, MagicService? magicService})
      : uiGenerator = uiTypeFactory(chosenMagic, magicService),
        super(key: key);

  final UITypeBase uiGenerator;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      init(constraints);
      return Scaffold(
        appBar: AppBar(
            actions: uiGenerator.type == MagicType.cancelMagic
                ? []
                : [
                    AppBarButton(
                      icon: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset('assets/images/magic/wand.png'),
                      ),
                      onPressed: () {
                        _onSave(context);
                      },
                      text: isTiny ? null : context.loc().magicModalSave,
                    )
                  ],
            backgroundColor: Colors.purple,
            title: Text(context.loc().magicModalTitle +
                ' ' +
                uiGenerator.title(context))),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: uiGenerator.buildCreateUI(context)
            ..insert(
                0,
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    uiGenerator.title(context),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                )),
        ),
      );
    });
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
                    child: Text(context.loc().gameOkButton,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                  )
                ],
                title: Text(
                  context.loc().magicAlertTitle,
                ),
                content: Text(errorTranslation),
              ));
    }
  }
}
