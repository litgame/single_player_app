import 'dart:async';

import 'package:file/file.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  final flipCardKey = GlobalKey<FlipCardState>();

  String imgUrl;
  String title;
  final imageLoadingFinishedStream = StreamController<bool>();
  bool _showImageLoader = false;

  void setImage(String imgUrl, String? title) {
    this.imgUrl = imgUrl;
    this.title = title ?? '';
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

  Widget _buildCardWithImage(BuildContext context) {
    if (_showImageLoader) {
      final cache = DefaultCacheManager();
      return FutureBuilder(
        future: cache.getSingleFile(imgUrl),
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
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
              return Image.memory(
                snapshot.data!.readAsBytesSync(),
                fit: BoxFit.fill,
              );
          }
        },
      );
    } else {
      return Image.asset(
        'assets/images/card_back.png',
        repeat: ImageRepeat.repeat,
      );
    }
  }

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
          child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child:
                  Builder(builder: (context) => _buildCardWithImage(context))),
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
            back: Card(
              elevation: 1.2,
              shadowColor: Colors.black,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child:
                  Builder(builder: (context) => _buildCardWithImage(context)),
            ),
            front: Card(
                elevation: 1.2,
                shadowColor: Colors.black,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Builder(builder: (context) {
                  if (_showImageLoader) {
                    return Center(
                      child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/card_back.png',
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
                      'assets/images/card_back.png',
                      repeat: ImageRepeat.repeat,
                    );
                  }
                })),
          ),
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
