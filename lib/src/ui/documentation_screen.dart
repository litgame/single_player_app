import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../tools.dart';
import 'menu_button.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen(
      {Key? key, required this.data, required this.onOk, double? textScale})
      : scale = textScale ?? 1.5,
        super(key: key);

  final String data;
  final double scale;
  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Markdown(
              styleSheet: MarkdownStyleSheet(textScaleFactor: 1.5), data: data),
        ),
        MenuButton(
          onPressed: onOk,
          text: context.loc().gameOkButton,
          stylePreset: MenuButtonStyle.tiny,
        )
      ],
    );
  }
}
