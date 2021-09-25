import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension Translate on BuildContext {
  AppLocalizations loc() {
    final locale = AppLocalizations.of(this);
    if (locale == null) throw ArgumentError('No locale available for context');
    return locale;
  }
}

mixin LayoutOrientation {
  var isTiny = true;
  var orientation = Orientation.portrait;

  void init(BoxConstraints constraints) {
    isTiny = constraints.maxWidth < 600;
    orientation = constraints.maxWidth > constraints.maxHeight
        ? Orientation.landscape
        : Orientation.portrait;
  }

  Widget buildLayout(BuildContext context, Widget child) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        init(constraints);
        return child;
      });
}
