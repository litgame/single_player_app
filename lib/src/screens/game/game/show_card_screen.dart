part of 'game_screen.dart';

class ShowCardScreen extends StatelessWidget {
  const ShowCardScreen({Key? key, this.future, required this.magicController})
      : super(key: key);

  final Future<lit_card.Card>? future;
  final MagicController magicController;

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<lit_card.Card> snapshot) {
          if (snapshot.hasData) {
            final card = snapshot.data as lit_card.Card;

            final cardWidget =
                CardItem(flip: false, imgUrl: card.imgUrl, title: card.name);

            if (magicController.noMagic) {
              return cardWidget;
            }

            final children = <Widget>[cardWidget];
            if (magicController.shouldSelectMagic) {
              children.add(Align(
                  alignment: const Alignment(0.95, -0.8),
                  child: MagicWidgetCreate(
                      chosenMagic: magicController.chosenMagicType,
                      magicService: magicController.service)));
            }

            if (magicController.shouldFireMagic) {
              children.add(Align(
                  alignment: const Alignment(0.95, -0.4),
                  child: MagicWidgetFire(
                    firedMagic: magicController.fireMagic,
                    magicService: magicController.service,
                  )));
            }
            return Stack(
              alignment: AlignmentDirectional.center,
              children: children,
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
