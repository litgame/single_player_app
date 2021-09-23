import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:single_player_app/src/services/game_rest.dart';

import '../../tools.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameService = GameRest();
    final controller = SettingsController();
    final futureResponse = gameService
        .request('GET', '/api/collection/list')
        .then((value) => value.fromJson());
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc().settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        // Glue the SettingsController to the theme selection DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(context.loc().settingsThemeTitle, textAlign: TextAlign.left),
              DropdownButton<ThemeMode>(
                // Read the selected themeMode from the controller
                value: controller.themeMode,
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: controller.updateThemeMode,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(context.loc().settingsThemeSystem),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(context.loc().settingsThemeLight),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(context.loc().settingsThemeDark),
                  )
                ],
              ),
              Text(context.loc().settingsCollectionTitle,
                  textAlign: TextAlign.left),
              FutureBuilder(
                  future: futureResponse,
                  initialData: null,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                    if (snapshot.hasData) {
                      final items = <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text(context.loc().settingsCollectionNone),
                        )
                      ];
                      final collectionsList = snapshot.data?['collections'];
                      if (collectionsList != null &&
                          collectionsList is List &&
                          collectionsList.isNotEmpty) {
                        for (var collection in collectionsList) {
                          items.add(DropdownMenuItem<String>(
                            value: collection['name'] as String,
                            child: Text(collection['name'] as String),
                          ));
                        }
                      }
                      return DropdownButton<String>(
                          value: controller.collectionName,
                          onChanged: controller.updateDefaultCollection,
                          items: items);
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            SpinKitWave(
                              color: Colors.green,
                              size: 35.0,
                            ),
                          ],
                        ),
                      );
                    }
                  }),
              CheckboxListTile(
                  title: Text(context.loc().gameTitleDocAllShow),
                  value: controller.showDocAllScreen,
                  onChanged: controller.updateShowDocAllScreen),
              CheckboxListTile(
                  title: Text(context.loc().gameTitleDocTrainingShow),
                  value: controller.showDocTrainingScreen,
                  onChanged: controller.updateShowDocTrainingScreen),
              CheckboxListTile(
                  title: Text(context.loc().gameTitleDocGameShow),
                  value: controller.showDocGameScreen,
                  onChanged: controller.updateShowDocGameScreen),
            ],
          ),
        ),
      ),
    );
  }
}
