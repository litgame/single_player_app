import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/settings/collection_widget.dart';
import 'package:single_player_app/src/services/game_rest.dart';

import '../../tools.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  GameRest get gameService => GameRest();

  SettingsController get controller => SettingsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
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
          builder: (BuildContext context, Widget? child) => ListView(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            // mainAxisAlignment: MainAxisAlignment.start,
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
              CollectionWidget(settings: controller),
              CheckboxListTile(
                  title: Text(context.loc().settingsWithMagic),
                  value: controller.withMagic,
                  onChanged: controller.updateWithMagic),
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
