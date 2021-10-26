import 'dart:async';
import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/screens/settings/settings_controller.dart';
import 'src/screens/settings/settings_service.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // HttpOverrides.global = MyHttpOverrides();
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final settingsController = SettingsController(SettingsService());
      await settingsController.loadSettings();

      CatcherOptions debugOptions =
          CatcherOptions(DialogReportMode(), [ConsoleHandler()]);

      CatcherOptions releaseOptions = CatcherOptions(SilentReportMode(), [
        ToastHandler(gravity: ToastHandlerGravity.bottom),
        ConsoleHandler(
            enableStackTrace: true,
            enableApplicationParameters: false,
            enableDeviceParameters: false)
      ], localizationOptions: [
        LocalizationOptions.buildDefaultRussianOptions()
      ]);

      Catcher(
          rootWidget: const MyApp(),
          debugConfig: releaseOptions,
          releaseConfig: releaseOptions);
    },
    (error, st) => print(error),
  );
}
