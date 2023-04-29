import 'dart:async';

import 'models/sync_response.dart';

class AutoSyncProcess {
  bool _syncProcessIsRunning = false;
  bool _stopAutoSync = false;
  bool _stopManualSync = false;
  bool _isAutoSync = false;
  late StreamController<SyncResponse> _syncStream;
  final String _successMessage = 'success';
  final String _failMessage = 'fail';
  final List<String> _autoSyncProcess = [];

  // for manual sync
  final List<String> _manualSyncProcess = [];

  static final AutoSyncProcess instance = AutoSyncProcess._();

  AutoSyncProcess._() {
    _syncStream = StreamController<SyncResponse>.broadcast();
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      setAutoSyncActions([
        'Get Dashboard',
        'Get cust Dashboard',
        'Get vendor Dashboard',
        'Get client Dashboard',
        'Get partner Dashboard',
        'Get something Dashboard',
      ]);
      await startAutoSyncProcess(forceStart: false);
    });
  }

  Stream<SyncResponse> get syncStream => _syncStream.stream;

  bool get stopAutoSync => _stopAutoSync;

  void setAutoSyncActions(List<String> process, {bool isImmediate = false}) {
    if (isImmediate) {
      _autoSyncProcess.insertAll(0, process);
    } else {
      _autoSyncProcess.addAll(process);
    }
  }

  Future<void> startAutoSyncProcess({bool? forceStart}) async {
    if (_syncProcessIsRunning) {
      _sendToView(SyncResponse(
          isAutoSync: _isAutoSync,
          name: 'Already running',
          isFinished: false,
          message: _failMessage,
          progress: 0,
          error: 'Already running'));
      return;
    }
    if (forceStart ?? true) _stopAutoSync = false;
    if (!_stopAutoSync) await _startAutoSync();
  }

  void stopAutoSyncProcess() {
    _stopAutoSync = true;
  }

  void stopManualSyncProcess() {
    _stopManualSync = true;
  }

  Future<void> _startAutoSync() async {
    // is auto sync is running
    _syncProcessIsRunning = true;
    //
    String actionName = '';
    _isAutoSync = true;
    if (_autoSyncProcess.isNotEmpty) {
      actionName = _autoSyncProcess.first;
    } else {
      return;
    }

    try {
      ///      don't write like this, should be use [completer]
      // await Future.delayed(const Duration(milliseconds: 1000));

      Completer<void> completer = Completer();
      Timer(const Duration(seconds: 1), () {
        completer.complete();
      });
      await completer.future;

      // finish sink stream
      _sendToView(_syncResponse(name: actionName));

      _autoSyncProcess.removeAt(0);
      // send
      _sendToView(_syncResponse(
        name: actionName,
        isFinished: _autoSyncProcess.isEmpty,
      ));
    } catch (e) {
      _syncProcessIsRunning = false;
      _stopAutoSync = false;
      _sendToView(_syncResponse(
          name: actionName,
          error: e.toString(),
          message: _failMessage,
          isFinished: true));
    }
    // assign auto sync is running or not
    _syncProcessIsRunning = _autoSyncProcess.isNotEmpty;

    // catch action list is empty, It's mean finish and force stop
    if (_autoSyncProcess.isEmpty || _stopAutoSync) {
      _syncProcessIsRunning = false;
      return;
    } else {
      await _startAutoSync();
    }
  }

  void _sendToView(SyncResponse response) {
    _syncStream.sink.add(response);
  }

  SyncResponse _syncResponse(
      {required String name,
      bool isFinished = false,
      String? error,
      double? progress,
      String? message}) {
    return SyncResponse(
        isAutoSync: _isAutoSync,
        name: name,
        error: error ?? '',
        progress: progress ?? 0.0,
        message: message ?? _successMessage,
        isFinished: isFinished);
  }

  Future<void> startManualSyncProcess(List<String> actionList) async {
    _isAutoSync = false;
    _stopManualSync = false;
    stopAutoSyncProcess();
    _manualSyncProcess.clear();
    _manualSyncProcess.addAll(actionList);
    // if (forceStart ?? true) _stopAutoSync = false;
    // if (!_stopAutoSync) await _startAutoSync();
    if (!_syncProcessIsRunning) await _startManualSync(actionList);
  }

  Future<void> _startManualSync(List<String> actionList) async {
    int index = (_manualSyncProcess.length - actionList.length) + 1;
    double progress = 0.0;
    int tempLength = _manualSyncProcess.length;

    // is manual sync is running
    _syncProcessIsRunning = true;
    //
    String actionName = '';
    _isAutoSync = false;
    if (actionList.isNotEmpty) {
      actionName = actionList.first;
    } else {
      return;
    }

    try {
      // don't write like this, should be use [completer]
      // await Future.delayed(const Duration(milliseconds: 1000));

      Completer<void> completer = Completer();
      Timer(const Duration(seconds: 1), () {
        completer.complete();
      });
      await completer.future;

      progress = index / tempLength;
      // finish sink stream
      _sendToView(_syncResponse(name: actionName, progress: progress));

      actionList.removeAt(0);
      // send
      _sendToView(_syncResponse(
        name: actionName,
        progress: progress,
        isFinished: actionList.isEmpty,
      ));
    } catch (e) {
      _syncProcessIsRunning = false;
      _stopAutoSync = false;
      _sendToView(_syncResponse(
          name: actionName,
          error: e.toString(),
          message: _failMessage,
          isFinished: true));
    }
    // assign auto sync is running or not
    _syncProcessIsRunning = actionList.isNotEmpty;

    // catch action list is empty, It's mean finish and force stop
    if (actionList.isEmpty || _stopManualSync) {
      _syncProcessIsRunning = false;
      _stopAutoSync = false;
      return;
    } else {
      await _startManualSync(actionList);
    }
  }
}

enum SyncProcess {
  autoSyncIdle,
  autoSyncProcessing,
  autoSyncFinished,
  autoSyncFailed,
  manualSyncIdle,
  manualSyncProcessing,
  manualSyncProcessFinished,
  manualSyncProcessFailed,
}

// void _checkFinishAndSend(String action, {ValueChanged<bool>? voidCallback}) {
//   if (_autoSyncProcess.isEmpty) {
//     _sendToView(
//       _syncResponse(name: action, isFinished: true),
//     );
//   }
//   voidCallback?.call(_autoSyncProcess.isEmpty);
// }
