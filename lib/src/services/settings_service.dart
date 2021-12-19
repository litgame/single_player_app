import 'dart:convert';

import 'package:flutter/material.dart' hide Card;
import 'package:litgame_server/models/cards/card.dart';
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

  Future<bool> withMagic() async =>
      (await _prefs()).getBool('withMagic') ?? false;

  Future<void> updateWithMagic(bool useMagic) =>
      _prefs().then((value) => value.setBool('withMagic', useMagic));

  Future<String> collection() async =>
      _prefs().then((value) => value.getString('collection') ?? 'default');

  Future<void> updateCollection(String collection) async =>
      _prefs().then((value) => value.setString('collection', collection));

  Future<void> saveCollection(
      String collectionName, Map<String, List<Card>> collection) async {
    final prefs = await _prefs();
    prefs.setString(
        'collection-$collectionName',
        jsonEncode(collection, toEncodable: (Object? nonEncodable) {
          if (nonEncodable is Card) {
            final map = nonEncodable.toJson();
            return map;
          }
          return '';
        }));
    final namesList = prefs.getStringList('collectionsOffline') ?? [];
    if (!namesList.contains(collectionName)) {
      namesList.add(collectionName);
      prefs.setStringList('collectionsOffline', namesList);
    }
  }

  Future<List<String>> getSavedCollectionsNames() =>
      _prefs().then((value) => value.getStringList('collectionsOffline') ?? []);

  Future<Map<String, List<Card>>?> getSavedCollection(
      String collectionName) async {
    final prefs = await _prefs();
    final collectionJson = prefs.getString('collection-$collectionName');
    if (collectionJson == null) return null;
    final collectionMap = jsonDecode(collectionJson);

    final result = <String, List<Card>>{};
    for (var type in CardType.values) {
      final cards = collectionMap[type.value()];
      if (cards == null) return null;
      if (result[type.value()] == null) {
        result[type.value()] = <Card>[];
      }

      for (var card in cards) {
        if (card is Map) {
          final newCard =
              Card(card['name'], card['imgUrl'], type, collectionName);
          result[type.value()]!.add(newCard);
        }
      }
    }
    return result;
  }

  Future<void> removeSavedCollection(String collectionName) =>
      _prefs().then((prefs) {
        final offline = prefs.getStringList('collectionsOffline') ?? <String>[];
        offline.remove(collectionName);
        prefs.setStringList('collectionsOffline', offline);
        prefs.remove('collection-$collectionName');
      });

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
