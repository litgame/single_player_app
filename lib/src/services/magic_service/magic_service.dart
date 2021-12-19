import 'package:single_player_app/src/screens/settings/settings_controller.dart';

class MagicService {
  MagicService(SettingsController settingsController)
      : _useMagic = settingsController.withMagic,
        _magicPlayersCount = settingsController.magicPlayersCount,
        _magicProbability = settingsController.magicProbability,
        _magicStartFromCycle = settingsController.magicStartFromCycle,
        _currentCycle = 1;

  bool _useMagic;
  int _magicPlayersCount;
  int _magicStartFromCycle;
  double _magicProbability;
  int _currentCycle;

  int nextCycle() => _currentCycle++;
}
