import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController._(this._settingsService);

  factory SettingsController([SettingsService? settingsService]) {
    if (settingsService != null) {
      _instance ??= SettingsController._(settingsService);
    } else if (_instance == null) {
      throw ArgumentError("settingsService can't be null");
    }
    return _instance as SettingsController;
  }

  static SettingsController? _instance;

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  String? _collectionName;
  bool _showDocAllScreen = true;
  bool _showDocGameScreen = true;
  bool _showDocTrainingScreen = true;
  List<String> _offlineCollections = [];

  String get collectionName => _collectionName ?? 'default';

  List<String> get offlineCollections => _offlineCollections;

  bool get isCurrentCollectionOffline =>
      offlineCollections.contains(collectionName);

  ThemeMode get themeMode => _themeMode;

  bool get showDocAllScreen => _showDocAllScreen;

  bool get showDocGameScreen => _showDocGameScreen;

  bool get showDocTrainingScreen => _showDocTrainingScreen;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _collectionName = await _settingsService.collection();
    _offlineCollections = await _settingsService.collectionsOffline();
    _showDocAllScreen = await _settingsService.showDocAllScreen();
    _showDocGameScreen = await _settingsService.showDocGameScreen();
    _showDocTrainingScreen = await _settingsService.showDocTrainingScreen();
    await dotenv.load(fileName: ".env");
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateDefaultCollection(String? newCollection) async {
    if (newCollection == null) return;

    if (newCollection == _collectionName) return;

    _collectionName = newCollection;

    notifyListeners();

    await _settingsService.updateCollection(newCollection);
  }

  Future<void> _updateOfflineCollections(
      List<String>? newCollectionsList) async {
    if (newCollectionsList == null) return;

    if (newCollectionsList == _offlineCollections) return;

    _offlineCollections = newCollectionsList;

    notifyListeners();

    await _settingsService.updateCollectionsOffline(newCollectionsList);
  }

  Future<void> setCollectionOffline(String collectionName) {
    final newList = offlineCollections.toList();
    if (!newList.contains(collectionName)) {
      newList.add(collectionName);
      return _updateOfflineCollections(newList);
    }
    return Future.value(null);
  }

  Future<void> setCollectionOnline(String collectionName) {
    final newList = offlineCollections.toList();
    if (newList.contains(collectionName)) {
      newList.remove(collectionName);
      return _updateOfflineCollections(newList);
    }
    return Future.value(null);
  }

  Future<void> updateShowDocAllScreen(bool? newValue) async {
    if (newValue == null) return;

    if (newValue == _showDocAllScreen) return;

    _showDocAllScreen = newValue;
    notifyListeners();

    await _settingsService.updateShowDocAllScreen(newValue);
  }

  Future<void> updateShowDocGameScreen(bool? newValue) async {
    if (newValue == null) return;

    if (newValue == _showDocGameScreen) return;

    _showDocGameScreen = newValue;
    notifyListeners();

    await _settingsService.updateShowDocGameScreen(newValue);
  }

  Future<void> updateShowDocTrainingScreen(bool? newValue) async {
    if (newValue == null) return;

    if (newValue == _showDocTrainingScreen) return;

    _showDocTrainingScreen = newValue;
    notifyListeners();

    await _settingsService.updateShowDocTrainingScreen(newValue);
  }
}
