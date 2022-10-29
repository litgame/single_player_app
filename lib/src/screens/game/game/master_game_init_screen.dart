part of 'game_screen.dart';

class MasterGameInit extends StatelessWidget {
  const MasterGameInit(
      {Key? key,
      required this.orientation,
      required this.isTiny,
      required this.future})
      : super(key: key);

  final Orientation orientation;
  final bool isTiny;
  final Future<List<lit_card.Card>> future;

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: future,
        builder: (BuildContext context,
            AsyncSnapshot<List<lit_card.Card>> snapshot) {
          if (snapshot.hasData) {
            final settings = SettingsController();
            var items = <Widget>[];
            for (var card in snapshot.data!) {
              if (settings.isDefaultCollection) {
                items.add(CardItem(
                  imgUrl: card.imgUrl,
                  title: card.name,
                  flip: false,
                ));
              } else {
                BgType bgType = BgType.fromLitType(card.cardType);
                items.add(CardItem(
                  imgUrl: card.imgUrl,
                  title: card.name,
                  flip: false,
                  bgType: bgType,
                ));
              }
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
