import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:litgame_server/litgame_server.dart';
import 'package:litgame_server/models/game/game.dart';
import 'package:litgame_server/service/service.dart';
import 'package:shelf/shelf.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';

class GameRest extends ServerlessService {
  GameRest._(LitGameRestService service) : super(service);

  static GameRest? _instance;

  factory GameRest() {
    _instance ??= GameRest._(LitGameRestService.manual(
        dotenv.get('PARSESERVER_URL'),
        dotenv.get('PARSESERVER_APP_KEY'),
        dotenv.get('PARSESERVER_MASTER_KEY'),
        dotenv.get('PARSESERVER_REST_KEY')));
    return _instance as GameRest;
  }
}

extension FromJson on Response {
  Future<Map<String, dynamic>> fromJson() async {
    final string = await readAsString();
    return jsonDecode(string);
  }
}

extension ToJson on Map {
  String toJson() => jsonEncode(this);
}

mixin GameService {
  final gameId = 'single';
  final playerId = 'player';

  GameRest get gameService => GameRest();

  bool get canPlay {
    final settings = SettingsController();
    if (settings.isNetworkOnline) return true;
    if (settings.playIsImpossible) return false;
    final game = LitGame.find('single');
    if (game == null) return true;
    final collection = game.gameFlow?.collectionName;
    if (collection == null) return true;
    return settings.offlineCollections
        .where((element) => element == collection)
        .isNotEmpty;
  }
}
