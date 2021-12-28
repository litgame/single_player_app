part of 'game_screen.dart';

class ShowCardScreen extends StatelessWidget
    with GameService, LayoutOrientation {
  ShowCardScreen({Key? key, this.future, required this.magicController})
      : super(key: key);

  final Future<lit_card.Card>? future;
  final MagicController magicController;

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<lit_card.Card> snapshot) {
          if (snapshot.hasData) {
            final card = snapshot.data as lit_card.Card;

            final cardWidget = _buildCardWidget(context, card);

            if (magicController.noMagic) {
              return cardWidget;
            }

            final children = <Widget>[cardWidget];
            if (magicController.shouldSelectMagic) {
              children.add(Align(
                  alignment: const Alignment(1.2, -0.95),
                  child: MagicWidgetCreate(
                      chosenMagic: magicController.chosenMagicType,
                      magicService: magicController.service)));
            }

            if (magicController.shouldFireMagic) {
              children.add(Align(
                  alignment: const Alignment(-1.2, -0.95),
                  child: MagicWidgetFire(
                    key: ValueKey<double>(Random().nextDouble()),
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

  Widget _buildCardWidget(BuildContext context, lit_card.Card card) {
    final selectedCardWidget =
        CardItem(flip: false, imgUrl: card.imgUrl, title: card.name);

    var showSingleCard = true;
    final futures = <Future<lit_card.Card>>[];
    for (var magic in magicController.fireMagic) {
      if (magic.type == MagicType.additionalEvent) {
        futures.add(selectCard(lit_card.CardType.generic));
        showSingleCard = false;
      }
    }
    if (showSingleCard) {
      return selectedCardWidget;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        init(constraints);
        return FutureBuilder(
            future: Future.wait<lit_card.Card>(futures),
            builder: (BuildContext context,
                AsyncSnapshot<List<lit_card.Card>> snapshot) {
              final items = <Widget>[];

              items.add(selectedCardWidget);
              if (snapshot.hasData) {
                final magicCards = snapshot.data as List<lit_card.Card>;
                for (var card in magicCards) {
                  items.add(CardItem(
                      flip: false, imgUrl: card.imgUrl, title: card.name));
                }
              } else {
                items.add(const Center(
                  child: SpinKitWave(
                    color: Colors.green,
                    size: 50.0,
                  ),
                ));
              }

              if (orientation == Orientation.portrait) {
                final aspectRatio = MediaQuery.of(context).size.width /
                    MediaQuery.of(context).size.width;

                return Center(
                  child: CarouselSlider(
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
            });
      },
    );
  }
}
