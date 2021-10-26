import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';
import 'package:single_player_app/src/services/image_service/image_service.dart';
import 'package:single_player_app/src/tools.dart';

class CollectionWidget extends StatefulWidget {
  const CollectionWidget(
      {Key? key, required this.menuItems, required this.settings})
      : super(key: key);

  final List<DropdownMenuItem<String>> menuItems;
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

  Map<String, double> savedProgress = {};

  @override
  void initState() {
    super.initState();
    buttonState = widget.settings.isCurrentCollectionOffline
        ? _DownloadState.finished
        : _DownloadState.idle;
    currentCollectionName = widget.settings.collectionName;
    notSelectedCollection = currentCollectionName.isEmpty;
  }

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
        if (savedProgress[widget.settings.collectionName] == null) {
          currentProgress = 0;
        } else {
          currentProgress = savedProgress[widget.settings.collectionName]!;
          if (currentProgress < 100) {
            buttonState = _DownloadState.inProgress;
          }
        }
      });
    });
  }

  void onDownloadCollection() {
    ImageService().downloadCollection(widget.settings.collectionName,
        onDownloadStart: onDownloadStart,
        onDownloadProgress: onDownloadProgress,
        onDownloadFinish: onDownloadFinish);
  }

  void onDownloadStart(String collectionName) {
    if (collectionName != currentCollectionName) return;

    setState(() {
      currentProgress = 0;
      buttonState = _DownloadState.inProgress;
    });
  }

  void onDownloadProgress(String collectionName, double progress) {
    if (collectionName != currentCollectionName) return;
    setState(() {
      currentProgress = progress;
      buttonState = _DownloadState.inProgress;
      savedProgress[collectionName] = progress;
    });
  }

  void onDownloadFinish(String collectionName) {
    widget.settings.setCollectionOffline(collectionName).then((value) {
      if (collectionName != currentCollectionName) return;
      setState(() {
        currentProgress = 100;
        buttonState = _DownloadState.finished;
        savedProgress[collectionName] = currentProgress;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
              value: widget.settings.collectionName,
              onChanged: updateDefaultCollection,
              items: widget.menuItems),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Builder(builder: (context) {
              if (notSelectedCollection) {
                return Container();
              }
              switch (buttonState) {
                case _DownloadState.idle:
                  return TextButton.icon(
                      onPressed: onDownloadCollection,
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
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(context.loc().scDownloadFinished),
                      )
                    ],
                  );
              }
            }),
          ),
        ]);
  }
}
