import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/tools.dart';
import 'package:single_player_app/src/ui/menu_button.dart';

class MagicPreGameSettings extends StatelessWidget {
  const MagicPreGameSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController();
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(context.loc().magicSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.loc().magicSettingsPlayersCount),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: SpinBox(
                  min: 2,
                  value: settings.magicPlayersCount.toDouble(),
                  onChanged: (value) {
                    settings.magicPlayersCount = value.toInt();
                  },
                ),
              ),
            ],
          ),
          Text(context.loc().magicStartFromCycle),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: SpinBox(
                  min: 1,
                  value: settings.magicStartFromCycle.toDouble(),
                  onChanged: (value) {
                    settings.magicStartFromCycle = value.toInt();
                  },
                ),
              ),
            ],
          ),
          Text(context.loc().magicProbability),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: SpinBox(
                  min: 0,
                  max: 100,
                  value: settings.magicProbability * 100,
                  onChanged: (value) {
                    settings.magicProbability = value / 100;
                  },
                ),
              ),
            ],
          ),
          MenuButton(
            onPressed: () {
              SettingsController().saveLastMagicSettings();
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
