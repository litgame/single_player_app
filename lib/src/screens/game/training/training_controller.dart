import 'package:flutter/material.dart';
import 'package:litgame_server/models/cards/card.dart' as LitCard;
import 'package:litgame_server/models/game/game.dart';
import 'package:single_player_app/src/screens/game/training/training_screen.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/game_rest.dart';
import 'package:single_player_app/src/ui/card_item.dart';
import 'package:swipeable_card_stack/swipe_controller.dart';

import '../doc/all.dart';
import '../doc/training.dart';

class TrainingController with GameService {
  TrainingController();

  final List<GlobalKey<CardItemState>> _cardKeys =
      List<GlobalKey<CardItemState>>.unmodifiable([
    GlobalKey<CardItemState>(debugLabel: 'one'),
    GlobalKey<CardItemState>(debugLabel: 'two'),
    GlobalKey<CardItemState>(debugLabel: 'three'),
  ]);

  late SwipeableCardSectionController cardSectionController;

  List<GlobalKey<CardItemState>> get cardKeys => _cardKeys;
  int _cardOnTopIndex = 0;

  GlobalKey<CardItemState> get cardOnTopKey => _cardKeys[_cardOnTopIndex];

  Future<LitCard.Card> nextCard() {
    var _state = cardOnTopKey.currentState;
    final flipState = _state?.flipCardKey.currentState;
    flipState?.toggleCard();

    _cardOnTopIndex++;
    if (_cardOnTopIndex == 3) {
      _cardOnTopIndex = 0;
    }
    _state = cardOnTopKey.currentState;
    return trainingNextStep().then((card) {
      if (_state != null) {
        _state.setImage(card.imgUrl, card.name);
      }
      return card;
    });
  }

  Future<LitCard.Card> startTraining() async {
    var response = await gameService.request('PUT', '/api/game/start',
        body: {'gameId': gameId, 'adminId': playerId}.toJson());
    if (response.statusCode != 200) {
      LitGame.find('single')?.stop();
      response = await gameService.request('PUT', '/api/game/start',
          body: {'gameId': gameId, 'adminId': playerId}.toJson());
      if (response.statusCode != 200) {
        throw "Game server error: can't start game";
      }
    }

    response = await gameService.request('PUT', '/api/game/setMaster',
        body: {
          'gameId': gameId,
          'triggeredBy': playerId,
          'targetUserId': playerId
        }.toJson());
    if (response.statusCode != 200) {
      throw "Game server error: can't set master";
    }

    response = await gameService.request('PUT', '/api/game/finishJoin',
        body: {
          'gameId': gameId,
          'triggeredBy': playerId,
        }.toJson());

    if (response.statusCode != 200) {
      throw "Game server error: can't finish join stage";
    }

    response = await gameService.request('PUT', '/api/game/sortPlayer',
        body: {
          'gameId': gameId,
          'triggeredBy': playerId,
          'targetUserId': playerId,
          'position': 0
        }.toJson());

    if (response.statusCode != 200) {
      throw "Game server error: can't sort player";
    }

    response = await gameService.request('PUT', '/api/game/training/start',
        body: {
          'gameId': gameId,
          'triggeredBy': playerId,
          'collectionName': SettingsController().collectionName
        }.toJson());

    if (response.statusCode != 200) {
      throw "Game server error: can't start training";
    }
    response = await gameService.request('PUT', '/api/game/training/next',
        body: {
          'gameId': gameId,
          'triggeredBy': playerId,
        }.toJson());

    if (response.statusCode != 200) {
      throw "Game server error: can't make first step";
    }

    currentCard = await response
        .fromJson()
        .then((value) => LitCard.Card.clone()..fromJson(value['card']));
    return currentCard!;
  }

  Future<LitCard.Card> trainingNextStep() async {
    final response = await gameService.request('PUT', '/api/game/training/next',
        body: {
          'gameId': gameId,
          'triggeredBy': playerId,
        }.toJson());
    if (response.statusCode != 200) {
      throw "Game server error: can't make next step";
    }

    currentCard = await response
        .fromJson()
        .then((value) => LitCard.Card.clone()..fromJson(value['card']));

    return currentCard!;
  }

  LitCard.Card? currentCard;

  static Widget buildRoute(BuildContext context, SettingsController settings) {
    if (settings.showDocAllScreen) {
      return const DocAllScreen();
    } else if (settings.showDocTrainingScreen) {
      return const DocTrainingScreen();
    }

    return TrainingScreen();
  }
}
