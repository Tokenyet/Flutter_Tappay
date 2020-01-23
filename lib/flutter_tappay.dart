import 'dart:async';

import 'package:flutter/services.dart';

class FlutterTappay {
  static const MethodChannel _channel =
      const MethodChannel('tokenyet.github.io/flutter_tappay');
  final EventChannel eventChannel;

  static FlutterTappay _instance;
  factory FlutterTappay() {
    if(_instance == null) {
      _instance = FlutterTappay.private();
    }
    return _instance;
  }

  FlutterTappay.private()
    : eventChannel = EventChannel('tokenyet.github.io/flutter_tappay_callback');

  /// Fires whenever the battery state changes.
  Stream<dynamic> get onTokenReceived {
    return eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
          print("收到: $event");
          return event;
    }   );
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> showPayment({
    String title,
    String btnName,
  }) async {
    await _channel.invokeMethod('showPayment', <String, String>{
      "title": title,
      "btnName": btnName
    });
  }

  static Future<String> getPrimeToken() async {
    final token = await _channel.invokeMethod('getToken');
    return token;
  }
}
