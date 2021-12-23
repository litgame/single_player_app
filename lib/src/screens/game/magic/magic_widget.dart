import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/magic_new_screen.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';

typedef MagicCallback = void Function(MagicItem item);

class MagicWidget extends StatefulWidget {
  const MagicWidget(
      {Key? key,
      required this.chosenMagic,
      required this.magicService,
      this.onMagicCreated})
      : super(key: key);

  final MagicType chosenMagic;
  final int basicSize = 64;
  static const swapDurationMS = Duration(milliseconds: 300);
  final MagicCallback? onMagicCreated;
  final MagicService magicService;

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

  Widget _buildAnimatedBox(BuildContext context) => GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Container(
                decoration: const BoxDecoration(
                    gradient: RadialGradient(radius: 0.5, colors: [
                  Color.fromRGBO(0, 0, 0, 0.9),
                  Color.fromRGBO(0, 0, 0, 0.8),
                  Color.fromRGBO(0, 0, 0, 0.4),
                  Color.fromRGBO(0, 0, 0, 0.05),
                  Color.fromRGBO(0, 0, 0, 0.0)
                ])),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Padding(
                    padding:
                        EdgeInsets.all((widget.basicSize * 0.5).toDouble()),
                    child: Image.asset(
                      'assets/images/magic/magic_box.png',
                      width: widget.basicSize.toDouble(),
                      height: widget.basicSize.toDouble(),
                    ),
                  ),
                ),
              );
            }),
      );

  Widget _buildOpenedBox(BuildContext context) {
    final random = Random();
    final imageNumber = random.nextInt(2) + 1;

    return Container(
      decoration: const BoxDecoration(
          gradient: RadialGradient(radius: 0.5, colors: [
        Color.fromRGBO(238, 108, 9, 0.9),
        Color.fromRGBO(238, 108, 9, 0.1),
        Color.fromRGBO(238, 108, 9, 0.05),
        Color.fromRGBO(0, 0, 0, 0.0)
      ])),
      child: Padding(
        padding: EdgeInsets.all((widget.basicSize / 2).toDouble()),
        child: Image.asset(
          'assets/images/magic/explosion_$imageNumber.png',
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
      Navigator.of(context)
          .push(MaterialPageRoute<MagicItem?>(
              fullscreenDialog: true,
              builder: (ctx) => MagicNewScreen(
                    magicService: widget.magicService,
                    chosenMagic: widget.chosenMagic,
                  )))
          .then((magicItem) {
        if (magicItem != null) {
          final callback = widget.onMagicCreated;
          if (callback != null) {
            callback(magicItem);
          }
          if (magicItem.type != MagicType.cancelMagic) {
            widget.magicService.allMagic.add(magicItem);
          }
          setState(() {
            _magicWidget = Container();
          });
        } else {
          setState(() {
            _magicWidget = _buildAnimatedBox(context);
          });
        }
      });
    });
  }
}
