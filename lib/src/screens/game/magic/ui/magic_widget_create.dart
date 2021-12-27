import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';

import '../magic_new_screen.dart';

class MagicWidgetCreate extends StatelessWidget {
  const MagicWidgetCreate(
      {Key? key, required this.magicService, required this.chosenMagic})
      : super(key: key);
  final MagicType chosenMagic;
  final MagicService magicService;

  MaterialPageRoute<MagicItem?> onAlertTap(BuildContext context) =>
      MaterialPageRoute<MagicItem?>(
          fullscreenDialog: true,
          builder: (ctx) => MagicNewScreen(
                magicService: magicService,
                chosenMagic: chosenMagic,
              ));

  bool onConfigFinish(MagicItem? magicItem) {
    if (magicItem == null) return true;

    if (magicItem.type != MagicType.cancelMagic) {
      magicService.allMagic.add(magicItem);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => MagicWidget(
        magicService: magicService,
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
