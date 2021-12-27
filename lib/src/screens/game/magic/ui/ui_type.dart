import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/ui/additional_event.dart';
import 'package:single_player_app/src/screens/game/magic/ui/eurythmics.dart';
import 'package:single_player_app/src/screens/game/magic/ui/keyword.dart';
import 'package:single_player_app/src/screens/game/magic/ui/marionette.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';

import 'cancel_magic.dart';

UITypeBase uiTypeFactory(MagicType type, MagicService? service) {
  switch (type) {
    case MagicType.marionette:
      return UITypeMarionette(type);

    case MagicType.eurythmics:
      return UITypeEurythmics(type);

    case MagicType.keyword:
      return UITypeKeyword(type);

    case MagicType.additionalEvent:
      return UITypeAdditionalEvent(type);

    case MagicType.cancelMagic:
      if (service == null) {
        throw ArgumentError('Need service instance for cancelMagic type');
      }
      return UITypeCancelMagic(type, service);
  }
}

abstract class UITypeBase {
  UITypeBase(this.type);

  final MagicType type;

  List<Widget> buildCreateUI(BuildContext context);

  List<Widget> buildViewUI(BuildContext context);

  MagicItem getMagicItem();

  void fillMagicData(MagicItem magicItem);

  String title(BuildContext context) => type.translatedName(context);
}

class ViewUIRow extends StatelessWidget {
  const ViewUIRow(this.child, {Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: child,
      );
}
