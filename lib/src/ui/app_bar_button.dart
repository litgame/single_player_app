import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  const AppBarButton(
      {required this.onPressed, required this.text, this.color, Key? key})
      : super(key: key);

  final VoidCallback? onPressed;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final background = color ?? Colors.green;
    final borderColor =
        Theme.of(context).colorScheme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(background),
          side: MaterialStateProperty.all<BorderSide>(BorderSide(
              width: 2, style: BorderStyle.solid, color: borderColor)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)))),
          padding:
              MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          textScaleFactor: 1.2,
        ),
      ),
    );
  }
}
