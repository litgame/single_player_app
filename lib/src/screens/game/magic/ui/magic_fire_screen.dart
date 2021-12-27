import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/ui/ui_type.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';
import 'package:single_player_app/src/tools.dart';

class MagicFireScreen extends StatelessWidget with LayoutOrientation {
  MagicFireScreen(
      {Key? key, required this.firedMagic, required this.magicService})
      : super(key: key);

  final List<MagicItem> firedMagic;
  final MagicService magicService;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      init(constraints);

      final children = <Widget>[];
      for (var magic in firedMagic) {
        final uiGen = uiTypeFactory(magic.type, magicService);
        uiGen.fillMagicData(magic);
        children.addAll(uiGen.buildViewUI(context));
        children.add(const Divider());
      }

      return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.purple,
            title: Text(context.loc().magicModalViewTitle)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: children,
        ),
      );
    });
  }
}
