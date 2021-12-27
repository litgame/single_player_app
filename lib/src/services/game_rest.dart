import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:litgame_server/litgame_server.dart';
import 'package:litgame_server/models/cards/card.dart';
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

  static List<Card>? _lastStartGameData;

  Future<List<Card>> startGame() async {
    final response = await gameService.request('PUT', '/api/game/game/start',
        body: {
          'gameId': gameId,
          'triggeredBy': playerId,
        }.toJson());

    if (response.statusCode != 200) {
      if (_lastStartGameData != null) return _lastStartGameData!;

      throw "Game server error: can't start game flow!";
    }
    _lastStartGameData = await response.fromJson().then((value) =>
        (value['initialCards'] as List)
            .map((card) => Card.clone()..fromJson(card))
            .toList(growable: false));

    return _lastStartGameData!;
  }

  void stopGame() async {
    LitGame.find(gameId)?.stop();
  }

  Future<Card> selectCard(CardType cardType) async {
    final response = await gameService.request(
        'PUT', '/api/game/game/selectCard',
        body: {
          'gameId': gameId,
          'triggeredBy': playerId,
          'selectCardType': cardType.value()
        }.toJson());

    if (response.statusCode != 200) {
      throw "Game server error: can't get new card!";
    }

    return response
        .fromJson()
        .then((value) => Card.clone()..fromJson(value['card']));
  }

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
