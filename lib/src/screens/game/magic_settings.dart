import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/tools.dart';
import 'package:single_player_app/src/ui/menu_button.dart';

class MagicSettings extends StatelessWidget {
  const MagicSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(context.loc().magicSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.loc().magicSettingsPlayersCount),
          SpinBox(
            min: 2,
            value: 4,
            onChanged: (value) {
              SettingsController().magicPlayersCount = value.toInt();
            },
          ),
          Text(context.loc().magicStartFromCycle),
          SpinBox(
            min: 1,
            value: 5,
            onChanged: (value) {
              SettingsController().magicStartFromCycle = value.toInt();
            },
          ),
          Text(context.loc().magicProbability),
          SpinBox(
            min: 0,
            max: 100,
            value: 30,
            onChanged: (value) {
              SettingsController().magicProbability = value / 100;
            },
          ),
          MenuButton(
            onPressed: () {
              Navigator.of(context)
                  .restorablePushNamed('/game/training/process');
            },
            text: context.loc().magicPlayButton,
            stylePreset: MenuButtonStyle.tiny,
          )
        ],
      ),
    );
  }
}
