part of image_service;

runDownloadIsolate(_DownloadTask task) async {
  final proc = _IsolatedProcess();
  proc.main(task);
}

class _ImageDownloader {
  _ImageDownloader(String collectionName, String savePath, this.onDownloadStart,
      this.onDownloadProgress, this.onDownloadFinish)
      : port = ReceivePort() {
    if (collectionName.isEmpty) {
      throw ArgumentError('Collection should be specified!', 'collectionName');
    }
    if (savePath.isEmpty) {
      throw ArgumentError('savePath should be specified!', 'savePath');
    }

    task = _DownloadTask(
      collectionName,
      savePath,
      port.sendPort,
      masterKey: dotenv.get('PARSESERVER_MASTER_KEY'),
      url: dotenv.get('PARSESERVER_URL'),
      appKey: dotenv.get('PARSESERVER_APP_KEY'),
      restKey: dotenv.get('PARSESERVER_REST_KEY'),
    );
  }

  ReceivePort port;
  StreamSubscription<dynamic>? _portSubscription;
  late _DownloadTask task;
  double progress = 0.0;

  Isolate? _isolate;

  Future<Isolate> run() async {
    if (_portSubscription != null) {
      throw ArgumentError('subscription did not cleared correctly');
    }
    _isolate ??= await Isolate.spawn<_DownloadTask>(runDownloadIsolate, task);
    _isolate!.addOnExitListener(port.sendPort, response: 'finish');
    _portSubscription = port.listen(_onData);
    return _isolate!;
  }

  Function onDownloadStart;
  Function onDownloadProgress;
  Function onDownloadFinish;

  void _onData(var message) {
    if (message is _DownloadMessage) {
      switch (message.status) {
        case _DownloadStatus.error:
          print('Isolate error: ' + message.errorDescription!);
          break;
        case _DownloadStatus.start:
          onDownloadStart(task.collectionName);
          break;
        case _DownloadStatus.run:
          progress = message.progress;
          onDownloadProgress(task.collectionName, message.progress);
          break;
        case _DownloadStatus.finish:
          _isolate = null;
          _portSubscription?.cancel().then((_) {
            _portSubscription = null;
          });
          onDownloadFinish(task.collectionName);
          break;
      }
    }
    if (message == 'finish') {
      _isolate = null;
      _portSubscription?.cancel().then((_) {
        _portSubscription = null;
      });
      onDownloadFinish(task.collectionName);
    }
  }
}

class _DownloadTask {
  _DownloadTask(
    this.collectionName,
    this.savePath,
    this.port, {
    required this.url,
    required this.appKey,
    required this.masterKey,
    required this.restKey,
  });

  String collectionName;
  String savePath;
  SendPort port;

  String url;
  String appKey;
  String masterKey;
  String restKey;
}

enum _DownloadStatus { error, start, run, finish }

class _DownloadMessage {
  _DownloadMessage(this.status, [this.progress = 0]);

  _DownloadStatus status;
  String? errorDescription;
  double progress;
}
