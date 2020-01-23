import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_tappay/flutter_tappay.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _token;
  FlutterTappay payer;

  @override
  void initState() {
    super.initState();
    payer = FlutterTappay();
    payer.onTokenReceived.listen((data) {
      setState(() {
        _token = data;
      });
    }, onError: (err){ print("$err");}, onDone: (){ print("done");});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text("Token on: $_token"),
            ],
          )
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            await FlutterTappay.showPayment(
              title: "Custom Title",
              btnName: "Custom BtnName",
              appKey: "app_whdEWBH8e8Lzy4N6BysVRRMILYORF6UxXbiOFsICkz0J9j1C0JUlCHv1tVJC",
              appId: 11334,
              serverType: FlutterTappayServerType.Sandbox
            );
          },
        ),
      ),
    );
  }
}
