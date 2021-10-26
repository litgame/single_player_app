part of image_service;

class _IsolatedProcess {
  late _DownloadTask _task;

  void main(_DownloadTask task) async {
    _task = task;
    final init = _init();
    final saveDir = Directory(task.savePath);
    final createdDir = await saveDir.create(recursive: true).catchError((_) {
      _sendError('Error creating new directory');
    });
    if (!createdDir.existsSync()) return;
    task.port.send(_DownloadMessage(_DownloadStatus.start));
    await init;
    final filesToDownload = await _getCollectionFiles(task.collectionName);
    if (filesToDownload == null) {
      _sendError('Cards of collection ${task.collectionName} did not found');
      return;
    }
    double totalProgress = 0;
    final progressFileStep = 100 / filesToDownload.length;
    for (var imgUrl in filesToDownload) {
      Response response = await Dio().get(
        imgUrl,
        onReceiveProgress: (int count, int total) {
          final perFileProgress = count * progressFileStep / total;
          final newProgress = totalProgress + perFileProgress;
          _sendProgress(newProgress);
        },
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              if (status == null) return false;
              return status < 500;
            }),
      );
      final fileName = imgUrl.split('/').last;
      if (response.data == null) {
        _sendError("File $imgUrl inaccessible, abort collection saving");
        return;
      }
      final file = File(task.savePath + '/' + fileName);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFrom(response.data).then((value) {
        raf.close();
        totalProgress += progressFileStep;
      });
    }
    var retry = 5;
    while (totalProgress < 99) {
      await Future.delayed(const Duration(seconds: 1));
      retry--;
      if (retry == 0) {
        totalProgress == 100;
      }
    }
    _sendProgress(totalProgress);
    final finishMessage = _DownloadMessage(_DownloadStatus.finish);
    task.port.send(finishMessage);
  }

  Future _init() {
    final service = LitGameRestService.manual(
        _task.url, _task.appKey, _task.masterKey, _task.restKey);
    return service.init;
  }

  Future<List<String>?> _getCollectionFiles(String collectionName) async {
    final builder = QueryBuilder<Card>(Card.clone())
      ..whereEqualTo('collection', collectionName);
    final response = await builder.query<Card>();
    if (response.results == null) {
      return null;
    }
    return response.results
        ?.map<String>((var card) => card.imgUrl)
        .toList(growable: false);
  }

  void _sendError(String description) {
    final errorMessage = _DownloadMessage(_DownloadStatus.error);
    errorMessage.errorDescription = description;
    _task.port.send(errorMessage);
  }

  void _sendProgress(double progress) {
    final message = _DownloadMessage(_DownloadStatus.run);
    message.progress = progress;
    _task.port.send(message);
  }
}
