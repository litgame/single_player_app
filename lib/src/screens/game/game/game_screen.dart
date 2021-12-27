import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:litgame_server/models/cards/card.dart' as lit_card;
import 'package:litgame_server/models/game/game.dart';
import 'package:single_player_app/src/screens/game/game/select_card_screen.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget_create.dart';
import 'package:single_player_app/src/screens/game/magic/ui/magic_widget_fire.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/game_rest.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/app_bar_button.dart';
import 'package:single_player_app/src/ui/card_item.dart';

import '../../../tools.dart';

part 'game_rest.dart';
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
  GameUIStage _currentState = GameUIStage.masterInit;
  lit_card.CardType? _selectedCartType;
  final _magicService = MagicService(SettingsController());
  MagicType? _currentPlayerChooseMagic;
  List<MagicItem> _fireMagic = [];

  Future<lit_card.Card>? _selectedCardFuture;
  _GameRest rest = _GameRest();

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
          _selectedCardFuture = rest.selectCard(type).then((card) {
            _currentPlayerChooseMagic = _magicService.addMagicAtTurn();
            _fireMagic = _magicService.applyMagicAtTurn();
            if (_fireMagic.isNotEmpty) {
              final magicWidget = MagicWidgetFire(
                  magicService: _magicService, firedMagic: _fireMagic);
              Navigator.of(context).push(magicWidget.onAlertTap(context));
            }
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
                child: _currentState == GameUIStage.masterInit
                    ? MasterGameInit(
                        orientation: orientation,
                        future: rest.startGame(),
                        isTiny: isTiny,
                      )
                    : _buildGameScreen(_currentState)));
      });

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
        builder: (BuildContext context, AsyncSnapshot<lit_card.Card> snapshot) {
          if (snapshot.hasData) {
            final card = snapshot.data as lit_card.Card;
            final cardWidget =
                CardItem(flip: false, imgUrl: card.imgUrl, title: card.name);
            if (_currentPlayerChooseMagic == null && _fireMagic.isEmpty) {
              return cardWidget;
            } else {
              final children = <Widget>[cardWidget];
              if (_currentPlayerChooseMagic != null) {
                children.add(Align(
                    alignment: const Alignment(0.95, -0.8),
                    child: MagicWidgetCreate(
                      chosenMagic: _currentPlayerChooseMagic!,
                      magicService: _magicService,
                    )));
              }
              if (_fireMagic.isNotEmpty) {
                children.add(Align(
                    alignment: const Alignment(0.95, -0.4),
                    child: MagicWidgetFire(
                      firedMagic: _fireMagic,
                      magicService: _magicService,
                    )));
              }
              return Stack(
                alignment: AlignmentDirectional.center,
                children: children,
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
        rest.stopGame();
        RouteBuilder.gotoMainMenu(context, reset: true);
      }
    });
  }
}
