import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:kplayer/kplayer.dart';
import 'package:litgame_server/models/cards/card.dart' as lit_card;
import 'package:litgame_server/models/game/game.dart';
import 'package:single_player_app/src/screens/game/game/magic_controller.dart';
import 'package:single_player_app/src/screens/game/game/select_card_screen.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget_create.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget_fire.dart';
import 'package:single_player_app/src/screens/game/training/training_controller.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/game_rest.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/app_bar_button.dart';
import 'package:single_player_app/src/ui/card_item.dart';

import '../../../tools.dart';

part 'master_game_init_screen.dart';
part 'restorable/displayed_cards.dart';
part 'restorable/game_ui_stage.dart';
part 'restorable/magic.dart';
part 'show_card_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

enum GameUIStage { masterInit, playerCardSelect, playerCardDisplay }

extension GameUIStageFromString on GameUIStage {
  GameUIStage fromString(String name) {
    switch (name) {
      case 'masterInit':
        return GameUIStage.masterInit;
      case 'playerCardSelect':
        return GameUIStage.playerCardSelect;
      case 'playerCardDisplay':
        return GameUIStage.playerCardDisplay;
    }
    throw ArgumentError('No such state: $name');
  }
}

class _GameScreenState extends State<GameScreen>
    with GameService, LayoutOrientation, NoNetworkModal, RestorationMixin {
  _GameScreenState() {
    restorableMagicController = _RestorableMagic(onApplyMagic);
  }

  final _currentStateRestorable = _RestorableGameUIStage();
  final _masterInitCardsRestorable = _RestorableDisplayedCards();
  final _selectedCardsRestorable = _RestorableDisplayedCards();
  late _RestorableMagic restorableMagicController;

  Future<List<lit_card.Card>>? _initGameRestorable;

  lit_card.CardType? _selectedCartType;

  Future<lit_card.Card>? _selectedCardFuture;
  late MagicController magicController;

  void onApplyMagic(MagicService service, List<MagicItem> magic) {
    if (SettingsController().soundOn) {
      Player.asset("assets/sounds/magic_happen.mp3").play();
    }
    if (SettingsController().vibrationOn) {
      Vibrate.vibrateWithPauses([
        const Duration(milliseconds: 150),
        const Duration(milliseconds: 300)
      ]);
    }
    final magicWidget =
        MagicWidgetFire(magicService: service, firedMagic: magic);
    Navigator.of(context).push(magicWidget.onAlertTap(context));
  }

  void nextUIState() {
    if (canPlay) {
      GameUIStage next;
      switch (_currentStateRestorable.value) {
        case GameUIStage.masterInit:
          next = GameUIStage.playerCardSelect;
          break;

        case GameUIStage.playerCardSelect:
          next = GameUIStage.playerCardDisplay;
          final type = _selectedCartType;
          if (type == null) {
            throw ArgumentError('CardType not specified!');
          }
          _selectedCardFuture = selectCard(type).then((card) {
            restorableMagicController.value.onCardSelect(card);
            _selectedCardsRestorable.value = [card];
            return card;
          });
          break;

        case GameUIStage.playerCardDisplay:
          next = GameUIStage.playerCardSelect;
          break;
      }

      setState(() {
        _currentStateRestorable.value = next;
      });
    } else {
      dlgNoNetwork(context);
    }
  }

  void _onGeneric() {
    _selectedCartType = lit_card.CardType.generic;
    nextUIState();
  }

  void _onPerson() {
    _selectedCartType = lit_card.CardType.person;
    nextUIState();
  }

  void _onPlace() {
    _selectedCartType = lit_card.CardType.place;
    nextUIState();
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        init(constraints);
        final actions = <Widget>[];
        if (_currentStateRestorable.value != GameUIStage.playerCardSelect) {
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
                  onPressed: _onGameEndButton,
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
                child: _buildGameScreen()));
      });

  Widget _buildGameScreen() {
    return FutureBuilder(
        future: _restoreGame(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            switch (_currentStateRestorable.value) {
              case GameUIStage.masterInit:
                _initGameRestorable ??= startGame();
                _initGameRestorable?.then((List<lit_card.Card> cards) {
                  _masterInitCardsRestorable.value = cards;
                });
                return MasterGameInit(
                  orientation: orientation,
                  future: _initGameRestorable!,
                  isTiny: isTiny,
                );

              case GameUIStage.playerCardSelect:
                _masterInitCardsRestorable.value = [];
                _selectedCardsRestorable.value = [];
                return SelectCardScreen(
                    key: UniqueKey(),
                    orientation: orientation,
                    isTiny: isTiny,
                    onGeneric: _onGeneric,
                    onPerson: _onPerson,
                    onPlace: _onPlace);

              case GameUIStage.playerCardDisplay:
                return ShowCardScreen(
                    magicController: restorableMagicController.value,
                    future: _selectedCardFuture);
            }
          } else {
            return const Center(
              child: SpinKitWave(
                color: Colors.green,
                size: 35.0,
              ),
            );
          }
        });
  }

  void _onGameEndButton() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(context.loc().gameFinishConfirmTitle),
              content: Text(context.loc().gameFinishConfirmDescription),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      context.loc().gameFinishConfirmNo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    )),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      context.loc().gameFinishConfirmYes,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
                    )),
              ],
            )).then((finish) {
      if (finish) {
        stopGame();
        RouteBuilder.gotoMainMenu(context, reset: true);
      }
    });
  }

  @override
  String? get restorationId => 'game';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_currentStateRestorable, 'ui_state');
    registerForRestoration(_masterInitCardsRestorable, 'master_init_cards');
    registerForRestoration(_selectedCardsRestorable, 'selected_cards');
    registerForRestoration(restorableMagicController, 'magic_controller');
  }

  Future _restoreGame() async {
    final game = LitGame.find(gameId);
    if (game != null) return true;
    final settings = SettingsController();
    final trainingController = TrainingController();
    Future trainingStarted;
    if (settings.isCurrentCollectionOffline) {
      trainingStarted = settings.getCurrentOfflineCollectionCards().then(
          (offlineCards) => trainingController.startTraining(
              settings.collectionName, offlineCards));
    } else {
      trainingStarted =
          trainingController.startTraining(settings.collectionName);
    }

    return trainingStarted.then((value) => startGame()).then((value) {
      switch (_currentStateRestorable.value) {
        case GameUIStage.masterInit:
          _initGameRestorable = Future.value(_masterInitCardsRestorable.value);
          break;
        case GameUIStage.playerCardSelect:
          // TODO: Handle this case.
          break;
        case GameUIStage.playerCardDisplay:
          _selectedCardFuture =
              Future.value(_selectedCardsRestorable.value.first);
          break;
      }
    });
  }
}
