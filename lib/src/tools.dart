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
  final data = _LayoutData();

  bool get isTiny => data.isTiny;

  Orientation get orientation => data.orientation;

  void init(BoxConstraints constraints) {
    data.isTiny = constraints.maxWidth < 600;
    data.orientation = constraints.maxWidth > constraints.maxHeight
        ? Orientation.landscape
        : Orientation.portrait;
  }
}

class _LayoutData {
  _LayoutData();

  var isTiny = true;
  var orientation = Orientation.portrait;
}
