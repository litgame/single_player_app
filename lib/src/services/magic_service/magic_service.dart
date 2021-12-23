import 'dart:math';

import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';

class MagicService {
  MagicService(SettingsController settingsController)
      : _useMagic = settingsController.withMagic,
        _magicPlayersCount = settingsController.magicPlayersCount,
        _magicProbability = settingsController.magicProbability,
        _magicStartFromCycle = settingsController.magicStartFromCycle,
        _currentCycle = 1,
        _currentTurn = 0;

  final bool _useMagic;
  final int _magicPlayersCount;
  final int _magicStartFromCycle;
  final double _magicProbability;
  int _currentCycle;
  int _currentTurn;

  Set<MagicItem> allMagic = {};

  MagicType? hasMagicAtTurn() {
    if (!_useMagic) return null;
    _currentTurn++;
    if (_currentTurn > _magicPlayersCount) {
      _currentCycle++;
      _currentTurn = 0;
    }
    if (_currentCycle < _magicStartFromCycle) return null;
    final rand = Random();
    if (rand.nextDouble() > _magicProbability) return null;
    return _getRandom();
  }

  MagicType? _getRandom([int? recursion]) {
    recursion ??= 0;
    final rand = Random();
    final typeIndex = rand.nextInt(MagicType.values.length);
    MagicType? magic = MagicType.values[typeIndex];
    if (magic == MagicType.cancelMagic && allMagic.isEmpty) {
      recursion++;
      if (recursion > 10) return null;
      magic = _getRandom(recursion);
    }
    return magic;
  }
}
