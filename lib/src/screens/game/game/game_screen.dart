import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:litgame_server/models/cards/card.dart' as LitCard;
import 'package:litgame_server/models/game/game.dart';
import 'package:single_player_app/src/screens/game/game/magic_widget.dart';
import 'package:single_player_app/src/screens/game/game/select_card_screen.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/game_rest.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/app_bar_button.dart';
import 'package:single_player_app/src/ui/card_item.dart';

import '../../../tools.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

enum GameUIStage { masterInit, playerCardSelect, playerCardDisplay }

class _GameScreenState extends State<GameScreen>
    with GameService, LayoutOrientation, NoNetworkModal {
  GameUIStage _currentState = GameUIStage.masterInit;
  LitCard.CardType? _selectedCartType;
  final carouselController = CarouselController();
  final _magicService = MagicService(SettingsController());
  MagicType? _currentPlayerChooseMagic;

  List<LitCard.Card>? _lastStartGameData;
  Future<LitCard.Card>? _selectedCardFuture;

  Future<List<LitCard.Card>> _restStartGame() async {
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

    _currentPlayerChooseMagic = _magicService.hasMagicAtTurn();

    return response
        .fromJson()
        .then((value) => LitCard.Card.clone()..fromJson(value['card']));
  }

  void nextUIState() {
    if (isCurrentCollectionPlayableOffline) {
      GameUIStage next;
      switch (_currentState) {
        case GameUIStage.masterInit:
          next = GameUIStage.playerCardSelect;
          break;
        case GameUIStage.playerCardSelect:
          next = GameUIStage.playerCardDisplay;
          _selectedCardFuture = _restSelectCard();
          break;
        case GameUIStage.playerCardDisplay:
          next = GameUIStage.playerCardSelect;
          break;
      }

      setState(() {
        _currentState = next;
      });
    } else {
      dlgNoNetwork(context);
    }
  }

  void _onGeneric() {
    _selectedCartType = LitCard.CardType.generic;
    nextUIState();
  }

  void _onPerson() {
    _selectedCartType = LitCard.CardType.person;
    nextUIState();
  }

  void _onPlace() {
    _selectedCartType = LitCard.CardType.place;
    nextUIState();
  }

  Widget _buildGameScreen(GameUIStage nextState) {
    if (nextState == GameUIStage.playerCardSelect) {
      return SelectCardScreen(
          key: UniqueKey(),
          orientation: orientation,
          isTiny: isTiny,
          onGeneric: _onGeneric,
          onPerson: _onPerson,
          onPlace: _onPlace);
    } else if (nextState == GameUIStage.playerCardDisplay) {
      return FutureBuilder(
        future: _selectedCardFuture,
        builder: (BuildContext context, AsyncSnapshot<LitCard.Card> snapshot) {
          if (snapshot.hasData) {
            final card = snapshot.data as LitCard.Card;
            final cardWidget =
                CardItem(flip: false, imgUrl: card.imgUrl, title: card.name);
            // _currentPlayerChooseMagic = MagicType.cancelMagic;
            //display floating magic box here!
            if (_currentPlayerChooseMagic == null) {
              return cardWidget;
            } else {
              return Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  cardWidget,
                  Align(
                      alignment: const Alignment(1, -0.8),
                      child: MagicWidget(onTap: () {}))
                ],
              );
            }
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
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        init(constraints);
        final actions = <Widget>[];
        if (_currentState != GameUIStage.playerCardSelect) {
          final text = isTiny ? null : context.loc().gameNextTurn;
          actions.add(AppBarButton(
            text: text,
            onPressed: nextUIState,
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 24.0,
              semanticLabel: context.loc().gameNextTurn,
            ),
          ));
        }
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.purple,
                leading: IconButton(
                  color: Colors.redAccent,
                  onPressed: () {
                    _restStopGame();
                    //TODO: переделать, чтобы было модальное окно с подтверждением завершения
                    RouteBuilder.gotoMainMenu(context, reset: true);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 24.0,
                    semanticLabel: context.loc().gameFinish,
                  ),
                ),
                title: Center(
                  child: Text(
                    context.loc().gameTitleGame,
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: actions),
            body: AnimatedSwitcher(
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(child: child, opacity: animation);
                },
                duration: const Duration(milliseconds: 200),
                child: _currentState == GameUIStage.masterInit
                    ? _buildMasterGameInit(context, orientation, isTiny)
                    : _buildGameScreen(_currentState)));
      });

  Widget _buildMasterGameInit(
      BuildContext context, Orientation orientation, bool isTiny) {
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

          if (orientation == Orientation.portrait) {
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
            return ListView(
              scrollDirection: Axis.horizontal,
              children: items,
            );
          }
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
