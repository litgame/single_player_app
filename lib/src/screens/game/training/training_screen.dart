import 'package:flutter/material.dart';
import 'package:litgame_server/models/cards/card.dart' as LitCard;
import 'package:single_player_app/src/screens/game/training/training_controller.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/app_bar_button.dart';
import 'package:single_player_app/src/ui/card_item.dart';
import 'package:swipeable_card_stack/swipeable_card_stack.dart';

import '../../../tools.dart';

class TrainingScreen extends StatelessWidget
    with LayoutOrientation, NoNetworkModal {
  TrainingScreen({Key? key}) : super(key: key) {
    training.cardSectionController = SwipeableCardSectionController();
  }

  final training = TrainingController();

  void onFlipDone(bool isFront) {
    if (isFront == true) return;
    training.cardSectionController.enableSwipe(true);
  }

  void _startTraining(String collectionName,
      [Map<String, List<LitCard.Card>>? offlineCards]) {
    training
        .startTraining(collectionName, offlineCards)
        .then((LitCard.Card card) {
      final firstCard = training.cardKeys[0];
      firstCard.currentState?.setImage(card.imgUrl, card.name);
    });
  }

  void _onGameStart(BuildContext context) {
    if (training.isCurrentCollectionPlayableOffline) {
      RouteBuilder.gotoTestFinishGameStart(context);
    } else {
      dlgNoNetwork(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController();
    if (settings.isCurrentCollectionOffline) {
      settings.getCurrentOfflineCollectionCards().then((offlineCards) =>
          _startTraining(settings.collectionName, offlineCards));
    } else {
      _startTraining(settings.collectionName);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        init(constraints);
        final text = isTiny ? null : context.loc().gameTitleTrainingFinish;
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.purple,
              title: Text(context.loc().gameTitleTraining),
              actions: [
                AppBarButton(
                  onPressed: () => _onGameStart(context),
                  text: text,
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 24.0,
                    semanticLabel: context.loc().gameTitleTrainingFinish,
                  ),
                )
              ],
            ),
            body: false
                ? Container()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SwipeableCardsSection(
                        cardController: training.cardSectionController,
                        context: context,
                        //add the first 3 cards (widgets)
                        items: [
                          CardItem(
                            onFlipDone: onFlipDone,
                            key: training.cardKeys[0],
                          ),
                          CardItem(
                            key: training.cardKeys[1],
                            onFlipDone: onFlipDone,
                          ),
                          CardItem(
                            key: training.cardKeys[2],
                            onFlipDone: onFlipDone,
                          )
                        ],
                        onCardSwiped: (dir, index, Widget widget) {
                          training.cardSectionController.enableSwipe(false);
                          training.cardSectionController.appendItem(CardItem(
                            key: widget.key,
                            empty: true,
                            onFlipDone: onFlipDone,
                          ));
                          training.nextCard();
                        },
                        //
                        enableSwipe: false,
                        enableSwipeUp: true,
                        enableSwipeDown: true,
                      ),
                    ],
                  ));
      },
    );
  }
}
