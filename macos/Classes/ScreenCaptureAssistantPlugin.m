#import "ScreenCaptureAssistantPlugin.h"

@interface ScreenCaptureAssistantPlugin() <FlutterStreamHandler>

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, copy) FlutterEventSink eventSink;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int windowID;
@property (nonatomic) CGRect lastWindowBounds;
 
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
    if ([@"startCheckWindowSize" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        int windowID = [arguments[@"windowID"] intValue];
        [self startTimerWith: windowID];
        result(@YES);
    } else if ([@"endCheckWindowSize" isEqualToString:call.method]) {
        [self stopTimer];
        result(@YES);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)startTimerWith:(int)windowID {
    [self stopTimer];
    self.windowID = windowID;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getWindowSize) userInfo:nil repeats:YES];
    [self.timer fire];
}


- (void)stopTimer{
    self.windowID = 0;
    self.lastWindowBounds = CGRectMake(0, 0, 0, 0);
    
    if (self.timer == NULL) return;
    [self.timer invalidate];
    self.timer = NULL;
}

- (void)getWindowSize {
    if (self.eventSink == NULL) return;
    
    CGRect rect = [self getWindowSizeWith: self.windowID];
    if (rect.size.width == self.lastWindowBounds.size.width && rect.size.height == self.lastWindowBounds.size.height) {
        return;
    }
    self.lastWindowBounds = rect;
    
    NSNumber *width = [NSNumber numberWithDouble:rect.size.width];
    NSNumber *height = [NSNumber numberWithDouble:rect.size.height];
    NSNumber *windowID = [NSNumber numberWithInt:self.windowID];
    NSDictionary *data = @{@"width": width, @"height": height, @"windowID": windowID};
    self.eventSink(@{@"event":@"onShareWindowResizeEvent", @"data": data});
}

- (CGRect)getWindowSizeWith:(int)windowID {
    NSMutableArray *windows = (NSMutableArray *)CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionAll, 0));

    CGRect bounds = CGRectMake(0, 0, 0, 0);
    for (NSDictionary *window in windows) {
        int  windowNumber = [[window objectForKey:@"kCGWindowNumber"] intValue];
        if (windowNumber != windowID) continue;
        NSString *name = [window objectForKey:@"kCGWindowOwnerName" ];
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[window objectForKey:@"kCGWindowBounds"], &bounds);
//        NSLog(@"windowID:%d name:%@   bounds:%@", windowNumber, name, NSStringFromRect(bounds));
        break;
    }
    return bounds;
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
