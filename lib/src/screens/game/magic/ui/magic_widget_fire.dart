import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';

import 'magic_fire_screen.dart';

class MagicWidgetFire extends StatelessWidget {
  const MagicWidgetFire(
      {Key? key, required this.magicService, required this.firedMagic})
      : super(key: key);
  final List<MagicItem> firedMagic;
  final MagicService magicService;

  MaterialPageRoute<MagicItem?> onAlertTap(BuildContext context) =>
      MaterialPageRoute<MagicItem?>(
          fullscreenDialog: true,
          builder: (ctx) => MagicFireScreen(
                magicService: magicService,
                firedMagic: firedMagic,
              ));

  /// Никогда не закрываем окно, чтобы игрок помнил о том, что должен сказать
  bool onConfigFinish(MagicItem? magicItem) => true;

  @override
  Widget build(BuildContext context) => MagicWidget(
        scaleAnimationOn: true,
        scaleFactor: 2,
        magicService: magicService,
        magicNotificationAssetPath: 'assets/images/magic/magic_sphere.gif',
        magicExplosionAssetPath: const [
          'assets/images/magic/explosion_1.png',
          'assets/images/magic/explosion_2.png',
        ],
        onAlertTap: onAlertTap,
        onConfigFinish: onConfigFinish,
      );
}
