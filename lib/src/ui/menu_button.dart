import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  const MenuButton(
      {required this.onPressed, required this.text, this.color, Key? key})
      : super(key: key);

  final VoidCallback? onPressed;
  final String text;
  final Color? color;

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
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(background),
            minimumSize: MaterialStateProperty.all(Size(minWidth, 100)),
            side: MaterialStateProperty.all<BorderSide>(BorderSide(
                width: 5, style: BorderStyle.solid, color: borderColor)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)))),
            padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.only(
                    top: 20, bottom: 20, left: 10, right: 10))),
        child: Text(
          text,
          textScaleFactor: 2.0,
        ),
      ),
    );
  }
}
