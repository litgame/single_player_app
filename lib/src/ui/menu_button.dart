import 'package:flutter/material.dart';

enum MenuButtonStyle { wide, tiny }

class MenuButton extends StatelessWidget {
  const MenuButton(
      {required this.onPressed,
      required this.text,
      this.stylePreset = MenuButtonStyle.wide,
      this.color,
      Key? key})
      : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final MenuButtonStyle stylePreset;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final minWidth =
        mediaQueryData.size.width - (mediaQueryData.size.width / 6) * 2;
    final background = color ?? Colors.green;
    final borderColor =
        Theme.of(context).colorScheme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: stylePreset == MenuButtonStyle.wide
            ? _wideStyle(borderColor, background, minWidth)
            : _tinyStyle(borderColor, background, minWidth),
        child: Text(
          text,
          textScaleFactor: 1.5,
        ),
      ),
    );
  }

  ButtonStyle _wideStyle(
          Color borderColor, Color background, double minWidth) =>
      ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(background),
          minimumSize: MaterialStateProperty.all(Size(minWidth, 100)),
          side: MaterialStateProperty.all<BorderSide>(BorderSide(
              width: 5, style: BorderStyle.solid, color: borderColor)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)))),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.only(top: 20, bottom: 20, left: 5, right: 5)));

  ButtonStyle _tinyStyle(
          Color borderColor, Color background, double minWidth) =>
      ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(background),
          minimumSize: MaterialStateProperty.all(Size(minWidth / 2, 50)),
          side: MaterialStateProperty.all<BorderSide>(BorderSide(
              width: 2, style: BorderStyle.solid, color: borderColor)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)))),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5)));
}
