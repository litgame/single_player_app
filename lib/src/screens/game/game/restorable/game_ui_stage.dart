part of '../game_screen.dart';

class _RestorableGameUIStage extends RestorableValue<GameUIStage> {
  @override
  GameUIStage createDefaultValue() => GameUIStage.masterInit;

  @override
  void didUpdateValue(GameUIStage? oldValue) {
    if (oldValue == null || oldValue.name != value.name) {
      notifyListeners();
    }
  }

  @override
  GameUIStage fromPrimitives(Object? data) {
    try {
      if (data != null) {
        return GameUIStage.masterInit.fromString(data as String);
      }
    } catch (_) {
      return createDefaultValue();
    }
    return createDefaultValue();
  }

  @override
  Object toPrimitives() {
    return value.name;
  }
}
