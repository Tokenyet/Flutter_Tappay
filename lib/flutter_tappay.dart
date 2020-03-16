import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum FlutterTappayServerType { Sandbox, Production }

@immutable
class TappayValidation {
  final bool isCardNumberValid;
  final bool isExpiryDateValid;
  final bool isCCVValid;
  final TappayCardValidType cardType;
  TappayValidation(
      {this.isCardNumberValid,
      this.isExpiryDateValid,
      this.isCCVValid,
      this.cardType});
}

enum TappayCardValidType {
  // Documentation cheat me with string value
//  CARD_TYPE_VISA,
//  CARD_TYPE_MASTERCARD,
//  CARD_TYPE_JCB,
//  CARD_TYPE_AMERICAN_EXPRESS,
//  CARD_TYPE_UNKNOWN
  visa,
  mastercard,
  jcb,
  american,
  unknown
}

enum CardDetailFundingType {
  credit,
  debit,
  prepaid,
}

enum CardDetailCardType { visa, mastercard, jcb, union, amex }

@immutable
class TappayTokenResponseCardDetail {
  final String bincode;
  final String lastFour;
  final String issuer;
  final CardDetailFundingType funding;
  final CardDetailCardType cardType;
  final String level;
  final String country;
  final String countryCode;
  TappayTokenResponseCardDetail({
    this.bincode,
    this.lastFour,
    this.issuer,
    this.funding,
    this.cardType,
    this.level,
    this.country,
    this.countryCode,
  });
}

@immutable
class TappayTokenResponse {
  final String prime;
  final TappayTokenResponseCardDetail cardInfo;
  final String cardIdentifier;
  TappayTokenResponse({
    this.prime,
    this.cardInfo,
    this.cardIdentifier,
  });
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
    if (_instance == null) {
      _instance = FlutterTappay.private();
    }
    return _instance;
  }

  FlutterTappay.private()
      : eventChannel =
            EventChannel('tokenyet.github.io/flutter_tappay_callback');

  /// Stream for listening the token from native activity
  ///
  ///  * [Documentation](https://docs.tappaysdk.com/tutorial/zh/android/front.html#tpdsetup)
  Stream<dynamic> get onTokenReceived {
    return eventChannel.receiveBroadcastStream().map((dynamic event) => event);
  }

  /// Show native payment to pay
  ///
  /// Show Android Activity consist of serveral arguments:
  ///
  /// [title] argument is used for Android scaffold Title
  /// [btnName] argument is used for Android pay btnName
  ///
  /// If there is a UI requirement, please fork the cardTypeproject and modify activity_main in layout folder
  ///  * [Documentation](https://docs.tappaysdk.com/tutorial/zh/android/front.html#tpdsetup)
  static Future<void> showPayment(
      {int appId,
      String appKey,
      FlutterTappayServerType serverType,
      String title,
      String btnName,
      String pendingBtnName,
      int androidReqCode = 8787}) async {
    // This might be constructed to delayed method, so onTokenReceived could be marked as deprecated in the future
    await _channel.invokeMethod('showPayment', <String, String>{
      "title": title,
      "btnName": btnName,
      "pendingBtnName": pendingBtnName,
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

  ///
  /// Use programmatically way to init, can't be used with Android way.
  ///
  Future<void> init({
    int appId,
    String appKey,
    FlutterTappayServerType serverType,
  }) async {
    // This might be constructed to delayed method, so onTokenReceived could be marked as deprecated in the future
    await _channel.invokeMethod('init', <String, String>{
      "appId": appId.toString(),
      "appKey": appKey,
      "serverType": describeEnum(serverType),
    });
  }

  ///
  /// Use programmatically way to valid card infos, can't be used with Android way.
  ///
  Future<TappayValidation> validate(
      {String cardNumber, String dueMonth, String dueYear, String ccv}) async {
    // This might be constructed to delayed method, so onTokenReceived could be marked as deprecated in the future
    Map<dynamic, dynamic> datas = await _channel
        .invokeMethod<Map<dynamic, dynamic>>('validate', <String, String>{
      "cardNumber": cardNumber,
      "dueMonth": dueMonth,
      "dueYear": dueYear,
      "ccv": ccv,
    });
    Map<String, String> data = datas.cast<String, String>();

    return new TappayValidation(
      isCardNumberValid: data["isCardNumberValid"] == "1",
      isExpiryDateValid: data["isExpiryDateValid"] == "1",
      isCCVValid: data["isCCVValid"] == "1",
      cardType: TappayCardValidType.values.firstWhere((value) {
        return describeEnum(value).toLowerCase() ==
            data["cardType"].toLowerCase();
      }, orElse: () => null),
    );
  }

  ///
  /// Use programmatically way to get card prime, can't be used with Android way.
  /// Must catch error If there is any.
  ///
  Future<TappayTokenResponse> sendToken(
      {String cardNumber, String dueMonth, String dueYear, String ccv}) async {
    // This might be constructed to delayed method, so onTokenReceived could be marked as deprecated in the future
    Map<dynamic, dynamic> datas = await _channel
        .invokeMethod<Map<dynamic, dynamic>>('sendToken', <String, String>{
      "cardNumber": cardNumber,
      "dueMonth": dueMonth,
      "dueYear": dueYear,
      "ccv": ccv,
    });
    Map<String, dynamic> data = datas.cast<String, dynamic>();

    TappayTokenResponseCardDetail detail = TappayTokenResponseCardDetail(
      bincode: data["cardInfoMap"]["bincode"],
      lastFour: data["cardInfoMap"]["lastFour"],
      issuer: data["cardInfoMap"]["issuer"],
      funding: CardDetailFundingType
          .values[int.parse(data["cardInfoMap"]["funding"])],
      cardType: CardDetailCardType
          .values[int.parse(data["cardInfoMap"]["cardType"]) - 1],
      level: data["cardInfoMap"]["level"],
      country: data["cardInfoMap"]["country"],
      countryCode: data["cardInfoMap"]["countryCode"],
    );

    return new TappayTokenResponse(
      prime: datas["prime"],
      cardInfo: detail,
      cardIdentifier: datas["cardIdentifier"],
    );
  }
}
