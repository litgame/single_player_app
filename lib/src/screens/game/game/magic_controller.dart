import 'package:litgame_server/models/cards/card.dart' as lit_card;
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';

typedef MagicUICallback = void Function(
    MagicService service, List<MagicItem> magic);

class MagicController {
  MagicController(this.onApplyMagic, [MagicService? magicService])
      : service = magicService ?? MagicService(SettingsController());

  final MagicService service;
  MagicType? _currentPlayerChooseMagic;
  List<MagicItem> _fireMagic = [];

  MagicUICallback onApplyMagic;

  void onCardSelect(lit_card.Card card) {
    _fireMagic = service.applyMagicAtTurn();
    _currentPlayerChooseMagic = service.addMagicAtTurn();
    if (shouldFireMagic) {
      onApplyMagic(service, _fireMagic);
    }
  }

  List<MagicItem> get fireMagic => _fireMagic.toList(growable: false);

  bool get shouldFireMagic => _fireMagic.isNotEmpty;

  bool get shouldSelectMagic => _currentPlayerChooseMagic != null;

  bool get noMagic => !shouldFireMagic && !shouldSelectMagic;

  MagicType get chosenMagicType {
    if (_currentPlayerChooseMagic == null) {
      throw 'No magic was chosen!';
    } else {
      return _currentPlayerChooseMagic!;
    }
  }

  Map<String, dynamic> toJson() => {
        '_currentPlayerChooseMagic': _currentPlayerChooseMagic?.name,
        '_fireMagic': _fireMagic.map((e) => e.toJson()).toList(),
        'service': service.toJson()
      };

  factory MagicController.fromJson(
      Map<String, dynamic> json, MagicUICallback onApplyMagic) {
    final serviceJson = json['service'];
    if (serviceJson == null) throw ArgumentError('Invalid JSON');
    final service = MagicService.fromJson(serviceJson, SettingsController());
    final controller = MagicController(onApplyMagic, service);
    final chooseMagicJson = json['_currentPlayerChooseMagic'];
    MagicType? chooseMagic;
    if (chooseMagicJson != null) {
      chooseMagic = MagicType.marionette.fromName(chooseMagicJson);
    }
    var fireMagicJson = json['_fireMagic'] ?? [];
    fireMagicJson as List;
    final fireMagic = fireMagicJson.map((e) => MagicItem.fromJson(e)).toList();
    controller._currentPlayerChooseMagic = chooseMagic;
    controller._fireMagic = fireMagic;
    return controller;
  }
}
