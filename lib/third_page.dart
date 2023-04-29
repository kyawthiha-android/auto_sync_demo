import 'dart:async';

import 'package:auto_sync_demo/sync_process.dart';
import 'package:flutter/material.dart';

import 'models/sync_response.dart';

class ThirdPage extends StatefulWidget {
  final String title;

  const ThirdPage({Key? key, required this.title}) : super(key: key);

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  late StreamSubscription<SyncResponse>? _autoSyncStream;

  @override
  void initState() {
    _autoSyncStream = AutoSyncProcess.instance.syncStream.listen((event) {
      AutoSyncProcess.instance.stopAutoSyncProcess();
      AutoSyncProcess.instance.stopManualSyncProcess();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {});
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<SyncResponse>(
                stream: AutoSyncProcess.instance.syncStream,
                builder: (context, snapshot) {
                  return Text(snapshot.data?.name ?? widget.title);
                },
              ),
              StreamBuilder<SyncResponse>(
                stream: AutoSyncProcess.instance.syncStream,
                builder: (context, snapshot) {
                  return Text(
                      'Auto sync is running ::${!AutoSyncProcess.instance.stopAutoSync}');
                },
              ),
              const SizedBox(height: 8),
              Text(widget.title),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoSyncStream?.cancel();
    super.dispose();
  }
}
