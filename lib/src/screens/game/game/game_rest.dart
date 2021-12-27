part of 'game_screen.dart';

class _GameRest with GameService {
  List<lit_card.Card>? _lastStartGameData;

  Future<List<lit_card.Card>> startGame() async {
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
            .map((card) => lit_card.Card.clone()..fromJson(card))
            .toList(growable: false));

    return _lastStartGameData!;
  }

  void stopGame() async {
    LitGame.find(gameId)?.stop();
  }

  Future<lit_card.Card> selectCard(lit_card.CardType cardType) async {
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
        .then((value) => lit_card.Card.clone()..fromJson(value['card']));
  }
}
