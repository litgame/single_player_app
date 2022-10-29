import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:litgame_server/models/cards/card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:single_player_app/src/services/game_rest.dart';
import 'package:vibration/vibration.dart';

import '../../services/settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController._(this._settingsService) {
    Connectivity().checkConnectivity().then((value) {
      _networkState = value;
    });
    _connectivitySubscr =
        Connectivity().onConnectivityChanged.listen(_onConnectionStateChanged);
  }

  factory SettingsController([SettingsService? settingsService]) {
    if (settingsService != null) {
      _instance ??= SettingsController._(settingsService);
    } else if (_instance == null) {
      throw ArgumentError("settingsService can't be null");
    }
    return _instance as SettingsController;
  }

  late StreamSubscription<ConnectivityResult> _connectivitySubscr;

  void _onConnectionStateChanged(ConnectivityResult result) {
    _networkState = result;
    if (!isNetworkOnline) {
      if (!isCurrentCollectionOffline) {
        if (offlineCollections.isEmpty) {
          _playIsImpossible = true;
        } else {
          updateDefaultCollection(offlineCollections.first, rebuild: false);
          _playIsImpossible = false;
        }
      }
    } else {
      _playIsImpossible = false;
    }
    notifyListeners();
  }

  var _networkState = ConnectivityResult.none;

  get networkState => _networkState;

  bool get isNetworkOnline => networkState != ConnectivityResult.none;

  static SettingsController? _instance;

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  String? _collectionName;
  bool _showDocAllScreen = true;
  bool _showDocGameScreen = true;
  bool _showDocTrainingScreen = true;
  bool _withMagic = false;
  bool _vibrationOn = true;
  bool _soundOn = true;

  int magicPlayersCount = 3;
  int magicStartFromCycle = 5;
  double magicProbability = 0.3;

  List<String> _offlineCollections = [];

  bool _playIsImpossible = false;

  bool get playIsImpossible => _playIsImpossible;

  String get collectionName => _collectionName ?? 'default';

  List<String> get offlineCollections => _offlineCollections;

  bool get isCurrentCollectionOffline =>
      offlineCollections.contains(collectionName);

  bool get isDefaultCollection => collectionName == 'default';

  ThemeMode get themeMode => _themeMode;

  bool get showDocAllScreen => _showDocAllScreen;

  bool get showDocGameScreen => _showDocGameScreen;

  bool get showDocTrainingScreen => _showDocTrainingScreen;

  bool get withMagic => _withMagic;
  bool get vibrationOn => _vibrationOn;
  bool get soundOn => _soundOn;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _collectionName = await _settingsService.collection();
    _offlineCollections = await _settingsService
        .getSavedCollectionsNames()
        .onError((error, stackTrace) {
      SharedPreferences.getInstance()
          .then((value) => value.remove('collectionsOffline'));
      return [];
    });
    _showDocAllScreen = await _settingsService.showDocAllScreen();
    _showDocGameScreen = await _settingsService.showDocGameScreen();
    _showDocTrainingScreen = await _settingsService.showDocTrainingScreen();
    _withMagic = await _settingsService.withMagic();

    _vibrationOn = false;
    try {
      bool? hasVibro = await Vibration.hasVibrator();
      if (hasVibro == true) {
        _vibrationOn = await _settingsService.vibrationOn();
      }
    } catch (_) {}
    _soundOn = await _settingsService.soundOn();

    magicPlayersCount = await _settingsService.lastMagicPlayers();
    magicStartFromCycle = await _settingsService.lastMagicCycles();
    magicProbability = await _settingsService.lastMagicProbability();

    await dotenv.load(fileName: "dotenv");
    GameRest();
    notifyListeners();
  }

  void saveLastMagicSettings() {
    _settingsService.setLastMagicCycles(magicStartFromCycle);
    _settingsService.setLastMagicPlayers(magicPlayersCount);
    _settingsService.setLastMagicProbability(magicProbability);
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateWithMagic(bool? withMagic) async {
    if (withMagic == null) return;
    if (withMagic == _withMagic) return;
    _withMagic = withMagic;
    notifyListeners();
    await _settingsService.updateWithMagic(_withMagic);
  }

  Future<void> updateSoundOn(bool? soundOn) async {
    if (soundOn == null) return;
    if (soundOn == _soundOn) return;
    _soundOn = soundOn;
    notifyListeners();
    await _settingsService.updateSound(_soundOn);
  }

  Future<void> updateVibrationOn(bool? vibrationOn) async {
    if (vibrationOn == null) return;
    if (vibrationOn == _vibrationOn) return;
    _vibrationOn = vibrationOn;
    notifyListeners();
    await _settingsService.updateSound(_vibrationOn);
  }

  Future<void> updateDefaultCollection(String? newCollection,
      {bool rebuild = true}) async {
    if (newCollection == null) return;

    if (newCollection == _collectionName) return;

    _collectionName = newCollection;

    if (rebuild) {
      notifyListeners();
    }

    await _settingsService.updateCollection(newCollection);
  }

  Future<void> saveCollection(
      String collectionName, Map<String, List<Card>> collection) {
    return _settingsService
        .saveCollection(collectionName, collection)
        .then((value) {
      _offlineCollections.add(collectionName);
      notifyListeners();
    });
  }

  Future<void> removeSavedCollection(String collectionName) =>
      _settingsService.removeSavedCollection(collectionName).then((value) {
        _offlineCollections.remove(collectionName);
        notifyListeners();
      });

  Future<Map<String, List<Card>>?> getCurrentOfflineCollectionCards() {
    if (!isCurrentCollectionOffline) return Future.value(null);

    return _settingsService.getSavedCollection(collectionName);
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

  @override
  dispose() {
    super.dispose();
    _connectivitySubscr.cancel();
  }
}
