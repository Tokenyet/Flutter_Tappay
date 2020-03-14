import Flutter
import UIKit


public class SwiftFlutterTappayPlugin: 	NSObject, FlutterPlugin, FlutterStreamHandler {
  var _eventSink: FlutterEventSink?;
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self._eventSink = events;
    return nil;
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil;
  }
  
  static let METHOD_CHANNEL_NAME = "tokenyet.github.io/flutter_tappay";
  static let EVENT_CHANNEL_NAME = "tokenyet.github.io/flutter_tappay_callback";
  static let DEFUALT_TITLE = "Tappay Example Title";
  static let DEFAULT_BTN_NAME = "Pay";
  static let DEFAULT_PENDING_BTN_NAME = "Paying...";
  static let SYSTEM_DEFAULT_APP_ID = 11334;
  static let SYSTEM_DEFAULT_APP_KEY = "app_whdEWBH8e8Lzy4N6BysVRRMILYORF6UxXbiOFsICkz0J9j1C0JUlCHv1tVJC";
  static let SYSTEM_DEFAULT_SERVER_TYPE = "sandbox";
  
  var viewController: UIViewController?;
  var eventChannel: FlutterEventChannel?;
  var methodChannel: FlutterMethodChannel?;
  
  public override init() {
    super.init();
    self.viewController = nil;
    self.eventChannel = nil;
    self.methodChannel = nil;
  }
    
  public func initData(viewController: UIViewController, registrar: FlutterPluginRegistrar) {
    //    super.init();
    self.viewController = viewController;
    self.methodChannel = FlutterMethodChannel(name: SwiftFlutterTappayPlugin.METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger());
    self.eventChannel = FlutterEventChannel(name: SwiftFlutterTappayPlugin.EVENT_CHANNEL_NAME, binaryMessenger: registrar.messenger());
    registrar.addMethodCallDelegate(self, channel: methodChannel!);
    print("Init Data!!!!!!!");
    eventChannel!.setStreamHandler(self);
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    print("register! a");
    let plugin = SwiftFlutterTappayPlugin();
    print("register! b");
    plugin.initData(
      viewController: (UIApplication.shared.delegate?.window??.rootViewController!)!,
      registrar: registrar
    );
    print("register! c");
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    //    result("iOS " + UIDevice.current.systemVersion)
    if (call.method == "getPlatformVersion") {
      result("iOS " + UIDevice.current.systemVersion)
    } else if(call.method == "showPayment") {
      guard let args = call.arguments else {
        return result(FlutterError());
      };
      if let myArgs = args as? [String: Any],
        let title = myArgs["title"] as? String,
        let btnName = myArgs["btnName"] as? String,
        let pendingBtnName = myArgs["pendingBtnName"] as? String,
        let appKey = myArgs["appKey"] as? String,
        let appId = myArgs["appId"] as? String,
        let serverType = myArgs["serverType"] as? String {
        
        let storyboard = UIStoryboard.init(name: "main", bundle: Bundle.init(for: ViewController.self))
        let controller = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        controller.initView(titleName: title, btnName: btnName, pendingBtnName: pendingBtnName, appKey: appKey, appId: appId, serverType: serverType)
        controller.onDismiss = {() -> Void in
            print(controller.token);
            self._eventSink!(controller.token)
        }
        
        
        viewController?.present(controller, animated: true, completion: { () -> Void in
        });

      }
      result("SUCCESS")
    } else if(call.method == "init") {
        
        guard let args = call.arguments else {
          return result(FlutterError());
        };
        if let myArgs = args as? [String: Any],
          let appKey = myArgs["appKey"] as? String,
          let appId = myArgs["appId"] as? String,
          let serverType = myArgs["serverType"] as? String {
//            TPDSetup.setWithAppId(
//                Int32(appId)!,
//                withAppKey: appKey,
//                with: serverType.lowercased() == "production" ? TPDServerType.production : TPDServerType.sandBox
//            )
            TPDSetup.setWithAppId(
                13873,
                withAppKey: "app_CBd97FKObDXQc40tbVMoGwu1BzTmPUBtCKMfzlSk2maiGb0GKUaKP7CCNTph",
                with: TPDServerType.sandBox
            )
            
            
            TPDSetup.shareInstance().serverSync()
            return result("SUCCESS")
        }
        return result(FlutterError())
    } else if(call.method == "validate") {
        guard let args = call.arguments else {
          return result(FlutterError());
        };
        if let myArgs = args as? [String: Any],
          let cardNumber = myArgs["cardNumber"] as? String,
          let dueMonth = myArgs["dueMonth"] as? String,
          let dueYear = myArgs["dueYear"] as? String,
          let ccv = myArgs["ccv"] as? String {
            let validResult = TPDCard.validate(
                withCardNumber: (cardNumber),
                withDueMonth: (dueMonth),
                withDueYear: (dueYear),
                withCCV: (ccv)
            )
            var map = Dictionary<String, String>()
            map["isCardNumberValid"] = validResult!.isCardNumberValid ? "1" : "0"
            map["isExpiryDateValid"] = validResult!.isExpiryDateValid ? "1" : "0"
            map["isCCVValid"] = validResult!.isCCVValid ? "1" : "0"
            map["cardType"] = String(describing: validResult!.cardType)
            return result(map);
        }
        return result(FlutterError());
    } else if(call.method == "sendToken") {
          guard let args = call.arguments else {
            return result(FlutterError());
          };
          print(args);
          if let myArgs = args as? [String: Any],
            let cardNumber = myArgs["cardNumber"] as? String,
            let dueMonth = myArgs["dueMonth"] as? String,
            let dueYear = myArgs["dueYear"] as? String,
            let ccv = myArgs["ccv"] as? String {
            var card = TPDCard.setWithCardNumber(
                (cardNumber),
                withDueMonth: (dueMonth),
                withDueYear: (dueYear),
                withCCV: (ccv)
            )
            card.onSuccessCallback { (prime, cardInfo) in
                // TDP's code is outdated and unmaintained, callback is not allowed cardIdentifier now, and can't find anywhere.
                let rawResult = "Prime : \(prime!),\n, \nLastFour : \(cardInfo!.lastFour!),\n Bincode : \(cardInfo!.bincode!),\n Issuer : \(cardInfo!.issuer!),\n cardType : \(cardInfo!.cardType),\n funding : \(cardInfo!.funding),\n country : \(cardInfo!.country!),\n countryCode : \(cardInfo!.countryCode!),\n level : \(cardInfo!.level!)"
                print(rawResult)
                var cardInfoMap = Dictionary<String, String>()
                cardInfoMap["bincode"] = cardInfo!.bincode
                cardInfoMap["lastFour"] = cardInfo!.lastFour
                cardInfoMap["issuer"] = cardInfo!.issuer
                cardInfoMap["funding"] = String(cardInfo!.funding)
                cardInfoMap["cardType"] = String(cardInfo!.cardType)
                cardInfoMap["level"] = cardInfo!.level
                cardInfoMap["country"] = cardInfo!.country
                cardInfoMap["countryCode"] = cardInfo!.countryCode
                print(cardInfoMap)
                var pack = Dictionary<String, Any>()
                pack["prime"] = prime
                pack["cardInfoMap"] = cardInfoMap
                pack["cardIdentifier"] = "not support in ios, idk why"
                print(pack)
                result(pack)
                // 3. Setup TPDCard on Failure Callback.
            }.onFailureCallback { (status, message) in
                let rawResult = "status : \(status),\n message : \(message)"
                print(rawResult);
                result(FlutterError(code: "\(status)", message: message, details: nil))
            // 4. Get Prime WIth TPDCard.
            }
            card.createToken(withGeoLocation: "UNKNOWN")
            return;
          }
          print("Miss value???");
          return result(FlutterError());
    }
  }
}
