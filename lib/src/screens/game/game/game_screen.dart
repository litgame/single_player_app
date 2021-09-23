import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:litgame_server/models/cards/card.dart' as LitCard;
import 'package:litgame_server/models/game/game.dart';
import 'package:single_player_app/src/services/game_rest.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/app_bar_button.dart';
import 'package:single_player_app/src/ui/card_item.dart';
import 'package:single_player_app/src/ui/menu_button.dart';

import '../../../tools.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

enum GameUIStage { masterInit, playerCardSelect, playerCardDisplay }

class _GameScreenState extends State<GameScreen> with GameService {
  GameUIStage _currentState = GameUIStage.masterInit;
  Widget? _currentWidget;
  LitCard.CardType? _selectedCartType;
  final carouselController = CarouselController();

  Future<List<LitCard.Card>> _restStartGame() async {
    final response = await gameService.request('PUT', '/api/game/game/start',
        body: {
          'gameId': gameId,
          'triggeredBy': playerId,
        }.toJson());

    if (response.statusCode != 200) {
      throw "Game server error: can't start game flow!";
    }
    return response.fromJson().then((value) => (value['initialCards'] as List)
        .map((card) => LitCard.Card.clone()..fromJson(card))
        .toList(growable: false));
  }

  void _restStopGame() async {
    LitGame.find(gameId)?.stop();
  }

  Future<LitCard.Card> _restSelectCard() async {
    final response =
        await gameService.request('PUT', '/api/game/game/selectCard',
            body: {
              'gameId': gameId,
              'triggeredBy': playerId,
              'selectCardType': _selectedCartType!.value()
            }.toJson());

    if (response.statusCode != 200) {
      throw "Game server error: can't get new card!";
    }

    return response
        .fromJson()
        .then((value) => LitCard.Card.clone()..fromJson(value['card']));
  }

  void nextUIState() {
    GameUIStage next;
    switch (_currentState) {
      case GameUIStage.masterInit:
        next = GameUIStage.playerCardSelect;
        break;
      case GameUIStage.playerCardSelect:
        next = GameUIStage.playerCardDisplay;
        break;
      case GameUIStage.playerCardDisplay:
        next = GameUIStage.playerCardSelect;
        break;
    }

    setState(() {
      _currentWidget = _buildGameScreen(next);
      _currentState = next;
    });
  }

  Widget _buildGameScreen(GameUIStage nextState) {
    if (nextState == GameUIStage.playerCardSelect) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuButton(
                  color: Colors.green,
                  onPressed: () {
                    _selectedCartType = LitCard.CardType.generic;
                    nextUIState();
                  },
                  text: context.loc().cardTypeGeneric),
              MenuButton(
                  color: Colors.lightGreen,
                  onPressed: () {
                    _selectedCartType = LitCard.CardType.person;
                    nextUIState();
                  },
                  text: context.loc().cardTypePerson),
              MenuButton(
                  color: Colors.teal,
                  onPressed: () {
                    _selectedCartType = LitCard.CardType.place;
                    nextUIState();
                  },
                  text: context.loc().cardTypePlace),
            ],
          ),
        ),
      );
    } else if (nextState == GameUIStage.playerCardDisplay) {
      return FutureBuilder(
        future: _restSelectCard(),
        builder: (BuildContext context, AsyncSnapshot<LitCard.Card> snapshot) {
          if (snapshot.hasData) {
            final card = snapshot.data as LitCard.Card;
            return CardItem(flip: false, imgUrl: card.imgUrl, title: card.name);
          } else {
            return const Center(
              child: SpinKitWave(
                color: Colors.green,
                size: 50.0,
              ),
            );
          }
        },
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: Text(context.loc().gameTitleGame),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBarButton(
                  color: Colors.redAccent,
                  onPressed: () {
                    _restStopGame();
                    //TODO: переделать, чтобы было модальное окно с подтверждением завершения
                    RouteBuilder.gotoMainMenu(context, reset: true);
                  },
                  text: context.loc().gameFinish),
              Text(context.loc().gameTitleGame),
              AppBarButton(
                  color: Colors.green,
                  onPressed: nextUIState,
                  text: context.loc().gameNextTurn)
            ],
          ),
        ),
        body: AnimatedSwitcher(
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(child: child, opacity: animation);
            },
            duration: const Duration(milliseconds: 200),
            child: _currentState == GameUIStage.masterInit
                ? _buildMasterGameInit(context)
                : _currentWidget));
  }

  Widget _buildMasterGameInit(BuildContext context) {
    return FutureBuilder(
      future: _restStartGame(),
      builder:
          (BuildContext context, AsyncSnapshot<List<LitCard.Card>> snapshot) {
        if (snapshot.hasData) {
          var items = <Widget>[];
          for (var card in snapshot.data!) {
            items.add(CardItem(
              imgUrl: card.imgUrl,
              title: card.name,
              flip: false,
            ));
          }

          final aspectRatio = MediaQuery.of(context).size.width /
              MediaQuery.of(context).size.width;

          return Center(
            child: CarouselSlider(
              carouselController: carouselController,
              options: CarouselOptions(
                  aspectRatio: aspectRatio,
                  onPageChanged: (int index, reason) {},
                  viewportFraction: 0.65,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  scrollDirection: Axis.horizontal),
              items: items,
            ),
          );
        } else {
          return const Center(
            child: SpinKitWave(
              color: Colors.green,
              size: 50.0,
            ),
          );
        }
      },
    );
  }
}
