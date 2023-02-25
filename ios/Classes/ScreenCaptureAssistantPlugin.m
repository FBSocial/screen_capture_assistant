#import "ScreenCaptureAssistantPlugin.h"

@interface ScreenCaptureAssistantPlugin() <FlutterStreamHandler>

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, copy) FlutterEventSink eventSink;

@end

@implementation ScreenCaptureAssistantPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"screen_capture_assistant" binaryMessenger:[registrar messenger]];
    ScreenCaptureAssistantPlugin* instance = [[ScreenCaptureAssistantPlugin alloc] init];
    instance.methodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"screen_capture_assistant_event" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"addObserverReplayKiteEvents" isEqualToString:call.method]) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        (__bridge const void *)(self),
                                        onBroadcastStarted,
                                        (CFStringRef)@"ZGStartedBroadcastUploadExtensionProcessENDNotification",
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        (__bridge const void *)(self),
                                        onBroadcastFinish,
                                        (CFStringRef)@"ZGFinishBroadcastUploadExtensionProcessENDNotification",
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
    } else if ([@"startObserverScreenCaptureDirection" isEqualToString:call.method]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDirectionChanged:) name:@"FANBOOK_DIRECTION_CHANGED" object:nil];

        CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
        CFStringRef identifierRef = (__bridge CFStringRef)@"DeviceOrientation";
        CFNotificationCenterAddObserver(center, (__bridge const void *)(self), onCaptureDirectionChanged, identifierRef, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        
    } else if ([@"stopObserverScreenCaptureDirection" isEqualToString:call.method]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FANBOOK_DIRECTION_CHANGED" object:nil];
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                           (__bridge const void *)(self),//(__bridge const void *)(self)
                                           (CFStringRef)@"DeviceOrientation",
                                           NULL);
        
    } else if ([@"checkScreenCaptureState" isEqualToString:call.method]) {
          /// 真正判断是否开启屏幕共享
          UIScreen *mainScreen = [UIScreen mainScreen];
          /// 只有在iOS11版本及以上才进行判断
          if (@available(iOS 11.0, *)) {
              ///mainScreen.isCaptured 为 true 表示当前已经开启屏幕共享，否则就没开启屏幕共享
              ///这里发送数据到flutter那边接收处理。
              if (mainScreen.isCaptured) {
                  if (self.eventSink != NULL) self.eventSink(@{@"event":@"screenCaptureState", @"data": @1});
              } else {
                  if (self.eventSink != NULL) self.eventSink(@{@"event":@"screenCaptureState", @"data": @0});
              }
      }
          
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void) onDirectionChanged:(NSNotification *)notice {
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.idreamsky.buff"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/data"];
    /// 获取从[ZGScreenCaptureManager.m]保存到本地的屏幕方向数据
    NSString *value = [NSString stringWithContentsOfURL:containerURL encoding:NSUTF8StringEncoding error:&err];

    if (err != nil) {
        NSLog(@"ScreenCaptureAssistantPlugin NotificationAction: %@",err);
        return;
    }
    
    if (self.eventSink == NULL) return;
    NSLog(@"ScreenCaptureAssistantPlugin eventSink: %@",@{@"event":@"direction", @"data": value});
    self.eventSink(@{@"event":@"direction", @"data": value});
}

void onCaptureDirectionChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, void const * object, CFDictionaryRef userInfo) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FANBOOK_DIRECTION_CHANGED" object:nil];
}

// Handle stop broadcast notification from main app process
void onBroadcastStarted(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSLog(@"ScreenCaptureAssistantPlugin onBroadcastStarted");

    ScreenCaptureAssistantPlugin *sender = (__bridge ScreenCaptureAssistantPlugin *)observer;
    [sender.methodChannel invokeMethod:@"screenShareState" arguments:@"fb_broadcastStartedWithSetupInfo"];

    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                       observer,//(__bridge const void *)(self)
                                       (CFStringRef)@"ZGStartedBroadcastUploadExtensionProcessENDNotification",
                                       NULL);
}

void onBroadcastFinish(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSLog(@"ScreenCaptureAssistantPlugin onBroadcastFinish");

    ScreenCaptureAssistantPlugin *sender = (__bridge ScreenCaptureAssistantPlugin *)observer;
    [sender.methodChannel invokeMethod:@"screenShareState" arguments:@"fb_broadcastFinished"];

    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                       observer,
                                       (CFStringRef)@"ZGFinishBroadcastUploadExtensionProcessENDNotification",
                                       NULL);
}

#pragma mark FlutterStreamHandler implementations
- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}

@end
