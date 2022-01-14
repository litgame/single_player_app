part of '../game_screen.dart';

class DisplayedCards extends RestorableValue<List<String>> {
  @override
  List<String> createDefaultValue() => <String>[];

  @override
  void didUpdateValue(List<String>? oldValue) {
    Function eq = const ListEquality().equals;
    if (oldValue == null || !eq(oldValue, value)) {
      notifyListeners();
    }
  }

  @override
  List<String> fromPrimitives(Object? data) {
    if (data != null) {
      return data as List<String>;
    }
    return createDefaultValue();
  }

  @override
  Object toPrimitives() {
    return value;
  }
}
