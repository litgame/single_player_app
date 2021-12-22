import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/ui/additional_event.dart';
import 'package:single_player_app/src/screens/game/magic/ui/eurythmics.dart';
import 'package:single_player_app/src/screens/game/magic/ui/keyword.dart';
import 'package:single_player_app/src/screens/game/magic/ui/marionette.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';

import 'cancel_magic.dart';

UITypeBase uiTypeFactory(MagicType type) {
  switch (type) {
    case MagicType.marionette:
      return UITypeMarionette();

    case MagicType.eurythmics:
      return UITypeEurythmics();

    case MagicType.keyword:
      return UITypeKeyword();

    case MagicType.additionalEvent:
      return UITypeAdditionalEvent();

    case MagicType.cancelMagic:
      return UITypeCancelMagic();
  }
}

abstract class UITypeBase {
  List<Widget> build(BuildContext context);

  MagicItem getMagicItem();

  String title(BuildContext context);
}
