import 'package:auto_sync_demo/sync_process.dart';
import 'package:auto_sync_demo/third_page.dart';
import 'package:flutter/material.dart';

import 'models/sync_response.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _currentDateTime = DateTime.now();

  @override
  void initState() {
    AutoSyncProcess.instance.setAutoSyncActions([
      'Get Dashboard',
      'Get cust Dashboard',
      'Get vendor Dashboard',
      'Get client Dashboard',
      'Get partner Dashboard',
      'Get something Dashboard',
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () =>
                  goNextRoute(context, const ThirdPage(title: "Third Page"))
                      .then((value) {
                AutoSyncProcess.instance.setAutoSyncActions([
                  'third page 1 action',
                  'third page 2 action',
                  'third page 3 action',
                  'third page 4 action',
                  'third page 5 action',
                  'third page 6 action',
                ], isImmediate: true);
                AutoSyncProcess.instance.startAutoSyncProcess();
              }),
              child: const Text('Page 3'),
            ),
            ElevatedButton(
              onPressed: () =>
                  goNextRoute(context, const ThirdPage(title: "Second Page"))
                      .then((value) {
                AutoSyncProcess.instance.setAutoSyncActions([
                  'second page 1 action',
                  'second page 2 action',
                  'second page 3 action',
                  'second page 4 action',
                  'second page 5 action',
                  'second page 6 action',
                ]);
                AutoSyncProcess.instance.startAutoSyncProcess();
              }),
              child: const Text('Page 2'),
            ),
            StreamBuilder<SyncResponse>(
              stream: AutoSyncProcess.instance.syncStream,
              builder: (context, snapshot) {
                print(snapshot.data?.toJson());
                if (snapshot.hasData) {
                  if (snapshot.data?.error.trim().isEmpty ?? false) {
                    print('SYNC :: ${snapshot.data?.toJson()}');
                    print(DateTime.now().difference(_currentDateTime));
                    _currentDateTime = DateTime.now();
                  }
                }
                return Text('${snapshot.data?.name}\n'
                    'auto sync:: ${snapshot.data?.isAutoSync}\n'
                    'sync process is running = ${!AutoSyncProcess.instance.stopAutoSync} \n'
                    'sync process is ${snapshot.data?.message} \n'
                    'progress ${snapshot.data?.progress} \n'
                    '');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AutoSyncProcess.instance.startManualSyncProcess([
          'master sync 1',
          'master sync 2',
          'master sync 3',
          'master sync 4',
          'master sync 5',
          'master sync 6',
          'master sync 7',
          'master sync 8',
        ]),
        tooltip: 'Master sync',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future goNextRoute(BuildContext context, Widget nextPage) {
  return Navigator.push(
      context, MaterialPageRoute(builder: (context) => nextPage));
}
