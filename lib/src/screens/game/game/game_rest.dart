part of 'game_screen.dart';

class _GameRest with GameService {
  List<LitCard.Card>? _lastStartGameData;

  Future<List<LitCard.Card>> startGame() async {
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
            .map((card) => LitCard.Card.clone()..fromJson(card))
            .toList(growable: false));

    return _lastStartGameData!;
  }

  void stopGame() async {
    LitGame.find(gameId)?.stop();
  }

  Future<LitCard.Card> selectCard(LitCard.CardType cardType) async {
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
        .then((value) => LitCard.Card.clone()..fromJson(value['card']));
  }
}
