library image_service;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:litgame_server/models/cards/card.dart' show Card;
import 'package:litgame_server/models/cards/card.dart';
import 'package:litgame_server/service/service.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:single_player_app/src/screens/settings/settings_controller.dart';

part 'downloader.dart';
part 'isolate.dart';

class ImageService {
  ImageService._();

  factory ImageService() {
    _instance ??= ImageService._();

    return _instance as ImageService;
  }

  static ImageService? _instance;

  final Map<String, _ImageDownloader> activeDownloaders = {};

  SettingsController get settings => SettingsController();

  Future<Image> getImage(String url) async {
    if (settings.isCurrentCollectionOffline) {
      final fileName = url.split('/').last;
      final collectionDir = await localCollectionPath;
      final file = File(collectionDir + '/' + fileName);
      final fileExists = await file.exists();
      if (fileExists) {
        return Image.file(
          file,
          fit: BoxFit.fill,
        );
      } else {
        _removeCurrentOfflineCollection();
        return _getCachedWebImage(url);
      }
    } else {
      return _getCachedWebImage(url);
    }
  }

  void downloadCollection(String collectionName,
      {required Function onDownloadStart,
      required Function onDownloadProgress,
      required Function onDownloadFinish}) async {
    final path = await localCollectionPath;
    final downloader = _ImageDownloader(
        collectionName, path, onDownloadStart, onDownloadProgress,
        (String collectionName, Map<String, List<Card>> collection) {
      activeDownloaders.remove(collectionName);
      onDownloadFinish(collectionName, collection);
    });
    activeDownloaders[collectionName] = downloader;
    downloader.run();
  }

  Future<void> removeCollection(String collectionName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path + '/LitGame/' + collectionName;
    final collectionDir = Directory(path);
    collectionDir.delete(recursive: true);
    return settings.removeSavedCollection(settings.collectionName);
  }

  Future<String> get localCollectionPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path + '/LitGame/' + settings.collectionName;
  }

  void _removeCurrentOfflineCollection() async {
    localCollectionPath.then((collectionPath) {
      final collectionDir = Directory(collectionPath);
      collectionDir.delete(recursive: true);
    });
    settings.removeSavedCollection(settings.collectionName);
  }

  Future<Image> _getCachedWebImage(String url) async {
    final cache = DefaultCacheManager();
    final result = await cache.getSingleFile(url);
    return Image.memory(
      result.readAsBytesSync(),
      fit: BoxFit.fill,
    );
  }
}
