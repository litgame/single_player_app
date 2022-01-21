part of '../game_screen.dart';

class _RestorableMagic extends RestorableValue<MagicController> {
  _RestorableMagic(this.onApplyMagic);

  MagicUICallback onApplyMagic;

  @override
  MagicController createDefaultValue() => MagicController(onApplyMagic);

  @override
  void didUpdateValue(MagicController? oldValue) {
    notifyListeners();
  }

  @override
  MagicController fromPrimitives(Object? data) {
    try {
      if (data != null) {
        return MagicController.fromJson(
            jsonDecode(data as String), onApplyMagic);
      }
    } catch (_) {
      return createDefaultValue();
    }
    return createDefaultValue();
  }

  @override
  void initWithValue(MagicController value) {
    super.initWithValue(value);
    value.addListener(notifyListeners);
  }

  @override
  void dispose() {
    value.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Object? toPrimitives() => jsonEncode(value.toJson());
}
