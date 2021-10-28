import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:litgame_server/models/cards/card.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/game_rest.dart';
import 'package:single_player_app/src/services/image_service/image_service.dart';
import 'package:single_player_app/src/tools.dart';

class CollectionWidget extends StatefulWidget {
  const CollectionWidget({Key? key, required this.settings}) : super(key: key);

  final SettingsController settings;

  @override
  _CollectionWidgetState createState() => _CollectionWidgetState();
}

enum _DownloadState { idle, inProgress, finished }

class _CollectionWidgetState extends State<CollectionWidget> {
  double currentProgress = 0;
  String currentCollectionName = "default";
  _DownloadState buttonState = _DownloadState.idle;
  bool notSelectedCollection = true;
  bool disposed = false;
  List<String> collectionsList = [];
  bool loadingCollection = true;

  GameRest get gameService => GameRest();

  @override
  void initState() {
    super.initState();
    loadingCollection = true;
    buttonState = widget.settings.isCurrentCollectionOffline
        ? _DownloadState.finished
        : _DownloadState.idle;
    currentCollectionName = widget.settings.collectionName;
    notSelectedCollection = currentCollectionName.isEmpty;

    if (!notSelectedCollection) {
      final runningProcess =
          ImageService().activeDownloaders[currentCollectionName];
      if (runningProcess != null) {
        currentProgress = runningProcess.progress;
        buttonState = _DownloadState.inProgress;
        runningProcess.onDownloadProgress = onDownloadProgress;
        runningProcess.onDownloadStart = onDownloadStart;
        runningProcess.onDownloadFinish = onDownloadFinish;
      }
    }
  }

  Future _getCollectionsList() => gameService
      .request('GET', '/api/collection/list')
      .then((value) => value.fromJson().then((value) {
            setState(() {
              collectionsList = ((value['collections'] ?? []) as List)
                  .map((e) => e['name'] as String)
                  .toList(growable: false);

              loadingCollection = false;
            });
          }));

  void updateDefaultCollection(String? newCollection) {
    if (newCollection != null && newCollection.isEmpty) {
      notSelectedCollection = true;
    } else {
      notSelectedCollection = false;
    }
    widget.settings.updateDefaultCollection(newCollection).then((_) {
      setState(() {
        buttonState = widget.settings.isCurrentCollectionOffline
            ? _DownloadState.finished
            : _DownloadState.idle;
        currentCollectionName = widget.settings.collectionName;
        var downloader =
            ImageService().activeDownloaders[currentCollectionName];

        if (downloader == null) {
          currentProgress = 0;
        } else {
          currentProgress = downloader.progress;
          if (currentProgress < 100) {
            buttonState = _DownloadState.inProgress;
          }
        }
      });
    });
  }

  void onDownloadButton() {
    ImageService().downloadCollection(widget.settings.collectionName,
        onDownloadStart: onDownloadStart,
        onDownloadProgress: onDownloadProgress,
        onDownloadFinish: onDownloadFinish);
  }

  void onDeleteButton() {
    ImageService().removeCollection(currentCollectionName).then((_) {
      if (disposed) return;
      setState(() {
        buttonState = widget.settings.isCurrentCollectionOffline
            ? _DownloadState.finished
            : _DownloadState.idle;
      });
    });
  }

  void onDownloadStart(String collectionName) {
    if (collectionName != currentCollectionName) return;
    if (disposed) return;
    setState(() {
      currentProgress = 0;
      buttonState = _DownloadState.inProgress;
    });
  }

  void onDownloadProgress(String collectionName, double progress) {
    if (collectionName != currentCollectionName) return;
    if (disposed) return;
    setState(() {
      currentProgress = progress;
      buttonState = _DownloadState.inProgress;
    });
  }

  void onDownloadFinish(
      String collectionName, Map<String, List<Card>> collection) {
    widget.settings.saveCollection(collectionName, collection).then((value) {
      if (collectionName != currentCollectionName) return;
      if (disposed) return;
      setState(() {
        currentProgress = 100;
        buttonState = _DownloadState.finished;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      if (collectionsList.isEmpty) {
        return FutureBuilder(
            future: _getCollectionsList(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return _buildCollectionDropdownLine(_prepareItems());
              } else {
                return _buildPreloader();
              }
            });
      } else {
        return _buildCollectionDropdownLine(_prepareItems());
      }
    }

    return _buildCollectionDropdownLine(_prepareItems());
  }

  bool get isOnline => widget.settings.isNetworkOnline;

  Widget _buildPreloader() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          SpinKitWave(
            color: Colors.green,
            size: 35.0,
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _prepareItems() {
    final items = <DropdownMenuItem<String>>[];
    if (isOnline) {
      items.add(DropdownMenuItem<String>(
        value: '',
        child: Text(context.loc().settingsCollectionNone),
      ));
      for (var collection in collectionsList) {
        items.add(DropdownMenuItem<String>(
          value: collection,
          child: Text(collection),
        ));
      }
    } else {
      collectionsList = [];
      for (var element in widget.settings.offlineCollections) {
        items.add(DropdownMenuItem<String>(
          value: element,
          child: Text(element),
        ));
      }
      if (items.isNotEmpty &&
          items
              .where(
                  (element) => element.value == widget.settings.collectionName)
              .isEmpty) {
        widget.settings
            .updateDefaultCollection(items.first.value, rebuild: false);
        notSelectedCollection = false;
      }
    }
    return items;
  }

  Widget _buildCollectionDropdownLine(
      List<DropdownMenuItem<String>> menuItems) {
    return LayoutBuilder(builder: (context, constraints) {
      if (menuItems.isEmpty) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                color: Colors.orange,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(context.loc().scNoNetwork),
              )
            ]);
      }
      return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
                value: widget.settings.collectionName,
                onChanged: updateDefaultCollection,
                items: menuItems),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Builder(builder: (context) {
                if (notSelectedCollection) {
                  return Container();
                }
                if (widget.settings.networkState == ConnectivityResult.none) {
                  return const Icon(
                    Icons.wifi_off,
                    color: Colors.orange,
                  );
                }
                switch (buttonState) {
                  case _DownloadState.idle:
                    return TextButton.icon(
                        onPressed: onDownloadButton,
                        icon: const Icon(
                          Icons.cloud_download_outlined,
                          color: Colors.green,
                        ),
                        label: Text(context.loc().scDownload));

                  case _DownloadState.inProgress:
                    return Row(
                      children: [
                        SizedBox(
                          width: 30.0,
                          height: 30.0,
                          child: Stack(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3, top: 4),
                                child: Icon(
                                  Icons.download_rounded,
                                  color: Colors.green,
                                ),
                              ),
                              CircularProgressIndicator(
                                strokeWidth: 1.5,
                                value: currentProgress / 100,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(context.loc().scDownloadProgress),
                        )
                      ],
                    );
                  case _DownloadState.finished:
                    return Row(
                      children: [
                        SizedBox(
                          width: 30.0,
                          height: 30.0,
                          child: Stack(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(left: 3, top: 4),
                                child: Icon(
                                  Icons.download_done_rounded,
                                  color: Colors.green,
                                ),
                              ),
                              CircularProgressIndicator(
                                strokeWidth: 1.5,
                                value: 1,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                        Builder(builder: (context) {
                          if (constraints.maxWidth > 320) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(context.loc().scDownloadFinished),
                            );
                          }
                          return Container();
                        }),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Builder(builder: (context) {
                            if (constraints.maxWidth > 365) {
                              return TextButton.icon(
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => Colors.red)),
                                  onPressed: onDeleteButton,
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  label: Text(context.loc().scDelete));
                            } else {
                              return TextButton.icon(
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => Colors.red)),
                                  onPressed: onDeleteButton,
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  label: const Text(''));
                            }
                          }),
                        )
                      ],
                    );
                }
              }),
            ),
          ]);
    });
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
