import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  const AppBarButton({required this.onPressed, this.text, this.icon, Key? key})
      : assert(
            text != null || icon != null, 'Either text or icon must be set!'),
        super(key: key);

  final VoidCallback? onPressed;
  final String? text;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1;
    final double gap =
        scale <= 1 ? 8 : lerpDouble(8, 4, math.min(scale - 1, 1))!;

    Widget? child;
    if (icon == null) {
      child = Text(text!);
    } else {
      final children = <Widget>[];
      if (text != null) {
        children.add(Flexible(child: Text(text!)));
        children.add(SizedBox(width: gap));
        children.add(icon!);
      } else {
        children.add(icon!);
      }

      child = Row(mainAxisSize: MainAxisSize.min, children: children);
    }
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
      onPressed: onPressed,
      clipBehavior: Clip.none,
      child: child,
    );
  }
}
