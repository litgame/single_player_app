import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension Translate on BuildContext {
  AppLocalizations loc() {
    final locale = AppLocalizations.of(this);
    if (locale == null) throw ArgumentError('No locale available for context');
    return locale;
  }
}
