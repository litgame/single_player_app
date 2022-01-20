part of '../game_screen.dart';

class _RestorableMagic extends RestorableValue<MagicController> {
  @override
  MagicController createDefaultValue() => MagicController((_, __) {});

  @override
  void didUpdateValue(MagicController? oldValue) {
    if (oldValue == null ||
        oldValue.fireMagic.length != value.fireMagic.length ||
        oldValue.chosenMagicType != value.chosenMagicType ||
        oldValue.service.allMagic != value.service.allMagic) {
      notifyListeners();
    }
  }

  @override
  MagicController fromPrimitives(Object? data) {
    try {
      if (data != null) {
        return MagicController.fromJson(jsonDecode(data as String), (_, __) {});
      }
    } catch (_) {
      return createDefaultValue();
    }
    return createDefaultValue();
  }

  @override
  Object? toPrimitives() => jsonEncode(value.toJson());
}
