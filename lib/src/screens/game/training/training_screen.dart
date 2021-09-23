import 'package:flutter/material.dart';
import 'package:litgame_server/models/cards/card.dart' as LitCard;
import 'package:single_player_app/src/screens/game/training/training_controller.dart';
import 'package:single_player_app/src/services/route_builder.dart';
import 'package:single_player_app/src/ui/app_bar_button.dart';
import 'package:single_player_app/src/ui/card_item.dart';
import 'package:swipeable_card_stack/swipeable_card_stack.dart';

import '../../../tools.dart';

class TrainingScreen extends StatelessWidget {
  TrainingScreen({Key? key}) : super(key: key) {
    training.cardSectionController = SwipeableCardSectionController();
  }

  final training = TrainingController();

  void onFlipDone(bool isFront) {
    if (isFront == true) return;
    training.cardSectionController.enableSwipe(true);
  }

  @override
  Widget build(BuildContext context) {
    final trainingStartFuture = training.startTraining();
    return Scaffold(
        appBar: AppBar(
          title: Text(context.loc().gameTitleTraining),
          actions: [
            AppBarButton(
                onPressed: () => RouteBuilder.gotoGameProcess(context),
                text: context.loc().gameTitleTrainingFinish)
          ],
        ),
        body: FutureBuilder(
          future: trainingStartFuture,
          builder:
              (BuildContext context, AsyncSnapshot<LitCard.Card> snapshot) {
            if (snapshot.hasData) {
              return Column(
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
                        imgUrl: snapshot.data!.imgUrl,
                        title: snapshot.data!.name,
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
                    enableSwipeUp: true,
                    enableSwipeDown: true,
                  ),
                ],
              );
            } else {
              return Column(
                key: GlobalKey(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SwipeableCardsSection(
                    cardController: training.cardSectionController,
                    context: context,
                    items: [
                      CardItem(
                        onFlipDone: onFlipDone,
                        key: training.cardKeys[0],
                      ),
                      CardItem(
                        onFlipDone: onFlipDone,
                        key: training.cardKeys[1],
                      ),
                      CardItem(
                        onFlipDone: onFlipDone,
                        key: training.cardKeys[2],
                      )
                    ],
                    enableSwipeUp: false,
                    enableSwipeDown: false,
                  ),
                ],
              );
            }
          },
        ));
  }
}
