import 'dart:math';

import 'package:flutter/material.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';

typedef MagicConfigOpenCallback = MaterialPageRoute<MagicItem?> Function(
    BuildContext context);

/// return true to keep notification on screen
/// return false to hide notification
typedef MagicConfigCloseCallback = bool Function(MagicItem? item);

class MagicWidget extends StatefulWidget {
  const MagicWidget(
      {Key? key,
      required this.chosenMagic,
      required this.magicService,
      required this.magicNotificationAssetPath,
      required this.magicExplosionAssetPath,
      required this.onAlertTap,
      required this.onConfigFinish,
      int? basicSize,
      bool? scaleAnimationOn,
      double? scaleFactor})
      : scaleAnimationOn = (scaleAnimationOn ?? true),
        basicSize = (basicSize ?? 64),
        scaleFactor = (scaleFactor ?? 2),
        super(key: key);

  final MagicType chosenMagic;
  final int basicSize;
  final double scaleFactor;
  static const swapDurationMS = Duration(milliseconds: 300);

  /// мы тапнули по ящику, он взорвался с анимсацией, после чего в этом колбэке
  /// должен открыться нужный роут с диалоговым окном
  final MagicConfigOpenCallback onAlertTap;

  /// Диалоговое окно роута закрылось, вернуло нам нечто, которое в этой
  /// функции мы должны обработать
  final MagicConfigCloseCallback onConfigFinish;

  final MagicService magicService;

  final String magicNotificationAssetPath;
  final List<String> magicExplosionAssetPath;

  final bool scaleAnimationOn;

  @override
  _MagicWidgetState createState() => _MagicWidgetState();
}

class _MagicWidgetState extends State<MagicWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Widget? _magicWidget;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInBack,
            reverseCurve: Curves.easeInBack))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _magicWidget ??= _buildAnimatedBox(context);
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      duration: MagicWidget.swapDurationMS,
      child: _magicWidget,
    );
  }

  Widget _buildAnimatedBox(BuildContext context) {
    Widget image = Padding(
      padding: EdgeInsets.all((widget.basicSize * 0.5).toDouble()),
      child: Image.asset(
        widget.magicNotificationAssetPath,
        width: widget.basicSize.toDouble(),
        height: widget.basicSize.toDouble(),
      ),
    );
    const decoration = BoxDecoration(
        gradient: RadialGradient(radius: 0.5, colors: [
      Color.fromRGBO(0, 0, 0, 0.9),
      Color.fromRGBO(0, 0, 0, 0.8),
      Color.fromRGBO(0, 0, 0, 0.4),
      Color.fromRGBO(0, 0, 0, 0.05),
      Color.fromRGBO(0, 0, 0, 0.0)
    ]));

    if (widget.scaleAnimationOn) {
      image = Container(
        decoration: decoration,
        child: Transform.scale(scale: _scaleAnimation.value, child: image),
      );
      image = AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Container(
              decoration: decoration,
              child:
                  Transform.scale(scale: _scaleAnimation.value, child: image),
            );
          });
    } else {
      image = Container(
        decoration: decoration,
        child: image,
      );
    }

    return GestureDetector(onTap: _onTap, child: image);
  }

  Widget _buildOpenedBox(BuildContext context) {
    final random = Random();
    final imageNumber = random.nextInt(widget.magicExplosionAssetPath.length);
    final assetPath = widget.magicExplosionAssetPath[imageNumber];

    return Transform.scale(
      scale: widget.scaleFactor,
      child: Padding(
        padding: EdgeInsets.all((widget.basicSize / 2).toDouble()),
        child: Image.asset(
          assetPath,
          width: widget.basicSize.toDouble(),
          height: widget.basicSize.toDouble(),
        ),
      ),
    );
  }

  void _onTap() {
    setState(() {
      _magicWidget = _buildOpenedBox(context);
    });
    Future.delayed(MagicWidget.swapDurationMS).then((_) {
      Navigator.of(context).push(widget.onAlertTap(context)).then((magicItem) {
        final keepNotificationOnScreen = widget.onConfigFinish(magicItem);

        if (keepNotificationOnScreen) {
          setState(() {
            _magicWidget = _buildAnimatedBox(context);
          });
        } else {
          setState(() {
            _magicWidget = Container();
          });
        }
      });
    });
  }
}
