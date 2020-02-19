import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_tappay/flutter_tappay.dart';
import 'package:flutter_tappay_example/tappay_android_way.dart';
import 'package:flutter_tappay_example/tappay_flutter_way.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              FlatButton(
                child: Text("Android way"),
                onPressed: (){
                  Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (context) {
                            return TappayAndroidScreen();
                          }
                      ));
                },
              ),
              FlatButton(
                child: Text("Flutter way"),
                onPressed: (){
                  Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (context) {
                            return TappayFlutterScreen();
                          }
                      ));
                },
              )
            ],
          )
      ),
    );
  }
}
