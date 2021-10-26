import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  Future<SharedPreferences> _prefs() async =>
      await SharedPreferences.getInstance();

  Future<void> updateThemeMode(ThemeMode theme) async =>
      _prefs().then((value) => value.setInt('theme', theme.toInt()));

  Future<ThemeMode> themeMode() async {
    final index = (await _prefs()).getInt('theme');
    if (index == null) return ThemeMode.system;
    try {
      return ThemeMode.values[index];
    } catch (_) {
      return ThemeMode.system;
    }
  }

  Future<String> collection() async =>
      _prefs().then((value) => value.getString('collection') ?? 'default');

  Future<void> updateCollection(String collection) async =>
      _prefs().then((value) => value.setString('collection', collection));

  Future<void> updateCollectionsOffline(List<String> collection) async =>
      _prefs().then((value) =>
          value.setString('collectionsOffline', collection.join(';')));

  Future<List<String>> collectionsOffline() async => _prefs().then(
      (value) => (value.getString('collectionsOffline') ?? '').split(';'));

  Future<bool> showDocAllScreen() =>
      _prefs().then((value) => value.getBool('showDocAllScreen') ?? true);

  Future<void> updateShowDocAllScreen(bool flag) async =>
      _prefs().then((value) => value.setBool('showDocAllScreen', flag));

  Future<bool> showDocGameScreen() =>
      _prefs().then((value) => value.getBool('showDocGameScreen') ?? true);

  Future<void> updateShowDocGameScreen(bool flag) async =>
      _prefs().then((value) => value.setBool('showDocGameScreen', flag));

  Future<bool> showDocTrainingScreen() =>
      _prefs().then((value) => value.getBool('showDocTrainingScreen') ?? true);

  Future<void> updateShowDocTrainingScreen(bool flag) async =>
      _prefs().then((value) => value.setBool('showDocTrainingScreen', flag));
}

extension IntConverter on ThemeMode {
  int toInt() => index;
}
