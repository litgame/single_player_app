import 'dart:async';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:single_player_app/src/services/image_service/image_service.dart';

class CardItem extends StatefulWidget {
  const CardItem(
      {Key? key,
      this.imgUrl = '',
      this.title = '',
      this.onFlipDone,
      this.empty,
      this.flip = true})
      : super(key: key);

  final String imgUrl;
  final String title;
  final bool? empty;
  final bool flip;
  final BoolCallback? onFlipDone;

  @override
  State<CardItem> createState() => CardItemState(imgUrl, title);
}

class CardItemState extends State<CardItem> {
  CardItemState([this.imgUrl = '', this.title = '']) {
    imageLoadingFinishedStream.stream.listen(_onImageLoaded);
  }

  static const bgCardImage = 'assets/images/bg_pattern.png';

  final flipCardKey = GlobalKey<FlipCardState>();

  String imgUrl;
  String title;
  final imageLoadingFinishedStream = StreamController<bool>();
  bool _showImageLoader = false;

  void setImage(String imgUrl, String? title) {
    setState(() {
      this.imgUrl = imgUrl;
      this.title = title ?? '';
    });
  }

  void _onImageLoaded(event) {
    _showImageLoader = false;
    flipCardKey.currentState?.toggleCard();
  }

  @override
  void didUpdateWidget(covariant CardItem oldWidget) {
    if (widget.empty == true) {
      imgUrl = '';
      title = '';
    } else {
      if (imgUrl.isEmpty && widget.imgUrl.isNotEmpty) {
        imgUrl = widget.imgUrl;
      }
      if (title.isEmpty && widget.title.isNotEmpty) {
        title = widget.title;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildImage(BuildContext context) {
    if (_showImageLoader) {
      final imgService = ImageService();
      return FutureBuilder(
        future: imgService.getImage(imgUrl),
        builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(
                child: SpinKitWave(
                  color: Colors.green,
                  size: 35.0,
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Icon(Icons.error);
              }
              imageLoadingFinishedStream.add(true);
              return snapshot.data!;
          }
        },
      );
    } else {
      if (title.isNotEmpty) {
        return Stack(
          children: [
            Image.asset(
              bgCardImage,
              repeat: ImageRepeat.repeat,
              height: MediaQuery.of(context).size.height,
            ),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(200, 255, 255, 255),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    shape: BoxShape.rectangle,
                    border: Border.all(
                        color: Colors.black,
                        style: BorderStyle.solid,
                        width: 1.0)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.2,
                  ),
                ),
              ),
            )
          ],
        );
      } else {
        return Image.asset(
          bgCardImage,
          repeat: ImageRepeat.repeat,
        );
      }
    }
  }

  Widget _buildCard(BuildContext context, Widget child) => Card(
      color: Colors.white,
      elevation: 10,
      shadowColor: const Color.fromARGB(255, 0, 0, 0),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.black, width: 1, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: child);

  @override
  Widget build(BuildContext context) {
    if (imgUrl.isNotEmpty) {
      _showImageLoader = true;
    }
    if (!widget.flip) {
      return Align(
        alignment: Alignment.topCenter,
        child: AspectRatio(
          aspectRatio: 0.67,
          child: _buildCard(context, _buildImage(context)),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: AspectRatio(
          aspectRatio: 0.67,
          child: FlipCard(
              key: flipCardKey,
              flipOnTouch: false,
              onFlipDone: widget.onFlipDone,
              direction: FlipDirection.HORIZONTAL,
              back: _buildCard(context, _buildImage(context)),
              front: _buildCard(context, Builder(builder: (context) {
                if (_showImageLoader) {
                  return Center(
                    child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            bgCardImage,
                            repeat: ImageRepeat.repeat,
                          ),
                          const SpinKitWave(
                            color: Colors.green,
                            size: 55.0,
                          ),
                        ]),
                  );
                } else {
                  return Image.asset(
                    bgCardImage,
                    repeat: ImageRepeat.repeat,
                  );
                }
              }))),
        ),
      );
    }
  }

  @override
  void dispose() {
    imageLoadingFinishedStream.close();
    super.dispose();
  }
}
