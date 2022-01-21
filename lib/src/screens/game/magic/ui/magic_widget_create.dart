import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/game/magic_controller.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';

import '../magic_new_screen.dart';

class MagicWidgetCreate extends StatelessWidget {
  const MagicWidgetCreate(
      {Key? key, required this.magicController, required this.chosenMagic})
      : super(key: key);
  final MagicType chosenMagic;
  final MagicController magicController;

  MaterialPageRoute<MagicItem?> onAlertTap(BuildContext context) =>
      MaterialPageRoute<MagicItem?>(
          fullscreenDialog: true,
          builder: (ctx) => MagicNewScreen(
                magicService: magicController.service,
                chosenMagic: chosenMagic,
              ));

  bool onConfigFinish(MagicItem? magicItem) {
    if (magicItem == null) return true;

    if (magicItem.type != MagicType.cancelMagic) {
      magicController.service.allMagic.add(magicItem);
    }
    magicController.markMagicChosen();
    return false;
  }

  @override
  Widget build(BuildContext context) => MagicWidget(
        magicService: magicController.service,
        magicNotificationAssetPath: 'assets/images/magic/magic_box.png',
        magicExplosionAssetPath: const [
          'assets/images/magic/explosion_1.png',
          'assets/images/magic/explosion_2.png',
          'assets/images/magic/explosion_3.png',
          'assets/images/magic/explosion_4.png',
          'assets/images/magic/explosion_5.png',
          'assets/images/magic/explosion_6.png',
        ],
        onAlertTap: onAlertTap,
        onConfigFinish: onConfigFinish,
      );
}
