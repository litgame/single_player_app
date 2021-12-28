import 'dart:math';

import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';

import 'magic_fire_screen.dart';

class MagicWidgetFire extends StatefulWidget {
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

  @override
  State<MagicWidgetFire> createState() => _MagicWidgetFireState();
}

class _MagicWidgetFireState extends State<MagicWidgetFire>
    with SingleTickerProviderStateMixin {
  Offset offset = const Offset(0, 0);

  late AnimationController controller;
  late Animation<Offset> translate;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    );

    updateOffset();

    translate = Tween<Offset>(
      begin: const Offset(0, 0),
      end: offset,
    ).animate(controller);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          final begin = Offset(offset.dx, offset.dy);
          updateOffset();

          translate = Tween<Offset>(
            begin: begin,
            end: offset,
          ).animate(controller);

          controller.reset();
          controller.forward();
        });
      }
    });
    controller.forward();

    super.initState();
  }

  void updateOffset() {
    final random = Random();
    final rad = random.nextDouble() * 6.28319;
    var distance = random.nextDouble() * 20;
    if (distance < 10) distance = 10;
    offset = Offset.fromDirection(rad, distance);
  }

  /// Никогда не закрываем окно, чтобы игрок помнил о том, что должен сказать
  bool onConfigFinish(MagicItem? magicItem) => true;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: translate.value,
            child: MagicWidget(
              scaleAnimationOn: false,
              scaleFactor: 2,
              magicService: widget.magicService,
              magicNotificationAssetPath:
                  'assets/images/magic/magic_sphere.gif',
              magicExplosionAssetPath: const [
                'assets/images/magic/explosion_1.png',
                'assets/images/magic/explosion_2.png',
              ],
              onAlertTap: widget.onAlertTap,
              onConfigFinish: onConfigFinish,
            ),
          );
        },
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
