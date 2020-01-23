import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum FlutterTappayServerType {
  Sandbox,
  Production
}

/// A flutter resolution for Tappay user
///
/// Currently support Android, iOS need wait or please and welcome to pull request :P
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


  /// Stream for listening the token from native activity
  ///
  ///  * [Documentation](https://docs.tappaysdk.com/tutorial/zh/android/front.html#tpdsetup)
  Stream<dynamic> get onTokenReceived {
    return eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event);
  }

  /// Show native payment to pay
  ///
  /// Show Android Activity consist of serveral arguments:
  ///
  /// [title] argument is used for Android scaffold Title
  /// [btnName] argument is used for Android pay btnName
  ///
  /// If there is a UI requirement, please fork the project and modify activity_main in layout folder
  ///  * [Documentation](https://docs.tappaysdk.com/tutorial/zh/android/front.html#tpdsetup)
  static Future<void> showPayment({
    int appId,
    String appKey,
    FlutterTappayServerType serverType,
    String title,
    String btnName,
    int androidReqCode = 8787
  }) async { // This might be constructed to delayed method, so onTokenReceived could be marked as deprecated in the future
    await _channel.invokeMethod('showPayment', <String, String>{
      "title": title,
      "btnName": btnName,
      "appId": appId.toString(),
      "appKey": appKey,
      "serverType": describeEnum(serverType),
      "androidRequestCode": androidReqCode.toString()
    });
  }

  /*static Future<String> getPrimeToken() async {
    final token = await _channel.invokeMethod('getToken');
    return token;
  }*/
}
