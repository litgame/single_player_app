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

  /// Можем ли мы добавить новую магию к игре на этом ходе?
  MagicType? addMagicAtTurn() {
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

  /// должна ли какая-то из добавленных ранее магий примениться на этом ходе?
  List<MagicItem> applyMagicAtTurn() {
    final magicToFire = <MagicItem>[];
    for (var item in allMagic) {
      item.fireAfterTurns--;
      if (item.fireAfterTurns == 0) {
        magicToFire.add(item);
      }
    }
    for (var item in magicToFire) {
      if (item.type != MagicType.eurythmics) {
        allMagic.remove(item);
      } else {
        item.fireAfterTurns = item.fireAfterTurnsOriginal;
      }
    }
    return magicToFire;
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

  Map<String, dynamic> toJson() => {
        '_currentCycle': _currentCycle,
        '_currentTurn': _currentTurn,
        'allMagic': allMagic.map((e) => e.toJson()).toList()
      };

  factory MagicService.fromJson(
      Map<String, dynamic> json, SettingsController settingsController) {
    final service = MagicService(settingsController);
    final currentCycle = json['_currentCycle'];
    if (currentCycle != null) {
      service._currentCycle = currentCycle;
    }
    final currentTurn = json['_currentTurn'];
    if (currentTurn != null) {
      service._currentTurn = currentTurn;
    }
    final allMagic = json['allMagic'];
    if (allMagic != null) {
      allMagic as List;
      service.allMagic = allMagic.map((e) => MagicItem.fromJson(e)).toSet();
    }
    return service;
  }
}
