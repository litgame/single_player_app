import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:kplayer/kplayer.dart';
import 'package:litgame_server/models/cards/card.dart' as lit_card;
import 'package:single_player_app/src/screens/game/game/magic_controller.dart';
import 'package:single_player_app/src/screens/game/game/select_card_screen.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget_create.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget_fire.dart';
import 'package:single_player_app/src/services/game_rest.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/app_bar_button.dart';
import 'package:single_player_app/src/ui/card_item.dart';

import '../../../tools.dart';

part 'master_game_init_screen.dart';
part 'show_card_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

enum GameUIStage { masterInit, playerCardSelect, playerCardDisplay }

class _GameScreenState extends State<GameScreen>
    with GameService, LayoutOrientation, NoNetworkModal {
  _GameScreenState() {
    magicController = MagicController(onApplyMagic);
  }

  GameUIStage _currentState = GameUIStage.masterInit;
  lit_card.CardType? _selectedCartType;

  Future<lit_card.Card>? _selectedCardFuture;
  late MagicController magicController;

  void onApplyMagic(MagicService service, List<MagicItem> magic) {
    Player.asset("assets/sounds/magic_happen.mp3").play();
    Vibrate.vibrateWithPauses(
        [const Duration(milliseconds: 150), const Duration(milliseconds: 300)]);
    final magicWidget =
        MagicWidgetFire(magicService: service, firedMagic: magic);
    Navigator.of(context).push(magicWidget.onAlertTap(context));
  }

  void nextUIState() {
    if (canPlay) {
      GameUIStage next;
      switch (_currentState) {
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
            magicController.onCardSelect(card);
            return card;
          });
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
    switch (_currentState) {
      case GameUIStage.masterInit:
        return MasterGameInit(
          orientation: orientation,
          future: startGame(),
          isTiny: isTiny,
        );

      case GameUIStage.playerCardSelect:
        return SelectCardScreen(
            key: UniqueKey(),
            orientation: orientation,
            isTiny: isTiny,
            onGeneric: _onGeneric,
            onPerson: _onPerson,
            onPlace: _onPlace);

      case GameUIStage.playerCardDisplay:
        return ShowCardScreen(
            magicController: magicController, future: _selectedCardFuture);
    }
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
}
