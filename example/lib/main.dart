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
    print("init");
    initPlatformState();
    payer = FlutterTappay();
    payer.onTokenReceived.listen((data) {
      print("Yo?$data Received");
      setState(() {
        print("!!$data");
        _token = data;
      });
    }, onError: (err){ print("$err");}, onDone: (){ print("done");});
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterTappay.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearflutter_tappayance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
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
              Text('Running on: $_platformVersion\n'),
              Text("Token on: $_token"),
              FlatButton(child: Text("123"), onPressed: () async {
                print(await FlutterTappay.getPrimeToken());
              },)
            ],
          )
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            print("tap");
            await FlutterTappay.showPayment(
              title: "Custom Title",
              btnName: "Custom BtnName"
            );
          },
        ),
      ),
    );
  }
}
