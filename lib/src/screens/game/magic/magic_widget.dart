import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MagicWidget extends StatefulWidget {
  const MagicWidget({Key? key, required this.onTap}) : super(key: key);

  final Function onTap;
  final int basicSize = 64;
  static const swapDurationMS = Duration(milliseconds: 300);

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
              final size = widget.basicSize * _scaleAnimation.value;
              return Container(
                decoration: const BoxDecoration(
                    gradient: RadialGradient(radius: 0.5, colors: [
                  Color.fromRGBO(0, 0, 0, 0.9),
                  Color.fromRGBO(0, 0, 0, 0.8),
                  Color.fromRGBO(0, 0, 0, 0.4),
                  Color.fromRGBO(0, 0, 0, 0.05),
                  Color.fromRGBO(0, 0, 0, 0.0)
                ])),
                child: Padding(
                  padding: EdgeInsets.all((widget.basicSize / 2).toDouble()),
                  child: Image.asset(
                    'assets/images/magic/magic_box.png',
                    width: size,
                    height: size,
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
        Color.fromRGBO(238, 108, 9, 0.8),
        Color.fromRGBO(238, 108, 9, 0.4),
        Color.fromRGBO(238, 108, 9, 0.05),
        Color.fromRGBO(0, 0, 0, 0.0)
      ])),
      child: Padding(
        padding: EdgeInsets.all((widget.basicSize / 2).toDouble()),
        child: Image.asset(
          'assets/images/magic/explosion_$imageNumber.png',
          width: 128,
          height: 128,
        ),
      ),
    );
  }

  void _onTap() {
    setState(() {
      _magicWidget = _buildOpenedBox(context);
    });
    Future.delayed(MagicWidget.swapDurationMS).then((_) {
      _onTap();
    });
  }
}
