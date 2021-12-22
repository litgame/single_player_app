import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/ui/marionette.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';

UITypeBase uiTypeFactory(MagicType type) {
  switch (type) {
    case MagicType.marionette:
      return UITypeMarionette();
    case MagicType.eurythmics:
      // TODO: Handle this case.
      break;
    case MagicType.keyword:
      // TODO: Handle this case.
      break;
    case MagicType.additionalEvent:
      // TODO: Handle this case.
      break;
    case MagicType.cancelMagic:
      // TODO: Handle this case.
      break;
  }
  return UITypeMarionette();
}

abstract class UITypeBase {
  List<Widget> build(BuildContext context);

  MagicItem getMagicItem();
}
