#import "FlutterTappayPlugin.h"
#if __has_include(<flutter_tappay/flutter_tappay-Swift.h>)
#import <flutter_tappay/flutter_tappay-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_tappay-Swift.h"
#endif

@implementation FlutterTappayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterTappayPlugin registerWithRegistrar:registrar];
}
@end
