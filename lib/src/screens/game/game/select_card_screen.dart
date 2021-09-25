import 'package:flutter/material.dart';
import 'package:single_player_app/src/ui/card_item.dart';
import 'package:single_player_app/src/ui/menu_button.dart';
import 'package:swipeable_card_stack/swipeable_card_stack.dart';

import '../../../tools.dart';

class SelectCardScreen extends StatelessWidget {
  const SelectCardScreen(
      {Key? key,
      required this.orientation,
      required this.isTiny,
      required this.onGeneric,
      required this.onPerson,
      required this.onPlace})
      : super(key: key);

  final Orientation orientation;
  final bool isTiny;

  final VoidCallback onGeneric;
  final VoidCallback onPerson;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    if (orientation == Orientation.portrait) {
      return _buildButtonsMenu(context);
    } else {
      return _buildCardsMenu(context);
    }
  }

  Widget _buildButtonsMenu(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: ListView(children: [
          MenuButton(
              color: Colors.green,
              onPressed: onGeneric,
              text: context.loc().cardTypeGeneric),
          MenuButton(
              color: Colors.lightGreen,
              onPressed: onPerson,
              text: context.loc().cardTypePerson),
          MenuButton(
              color: Colors.teal,
              onPressed: onPlace,
              text: context.loc().cardTypePlace),
        ]),
      );

  Widget _buildCardBlock(
          BuildContext context, String title, VoidCallback callback) =>
      SwipeableCardsSection(
        context: context,
        items: List<Widget>.filled(
            3,
            CardItem(
              flip: false,
              imgUrl: '',
              title: title,
            )),
        onCardSwiped: (dir, index, Widget widget) {
          callback();
          return false;
        },
        enableSwipeUp: true,
        enableSwipeDown: true,
      );

  Widget _buildCardsMenu(BuildContext context) => Row(
        children: [
          _buildCardBlock(context, context.loc().cardTypeGeneric, onGeneric),
          _buildCardBlock(context, context.loc().cardTypePerson, onPerson),
          _buildCardBlock(context, context.loc().cardTypePlace, onPlace),
        ],
      );
}
