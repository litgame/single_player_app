import 'package:litgame_server/models/cards/card.dart' as lit_card;
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';

typedef MagicUICallback = void Function(
    MagicService service, List<MagicItem> magic);

class MagicController {
  MagicController(this.onApplyMagic);

  final service = MagicService(SettingsController());
  MagicType? _currentPlayerChooseMagic;
  List<MagicItem> _fireMagic = [];

  MagicUICallback onApplyMagic;

  void onCardSelect(lit_card.Card card) {
    _currentPlayerChooseMagic = service.addMagicAtTurn();
    _fireMagic = service.applyMagicAtTurn();
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
}
