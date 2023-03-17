#import "ScreenCaptureAssistantPlugin.h"
#include <libproc.h>

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
    } else if ([@"getWindowSize" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        int windowID = [arguments[@"windowID"] intValue];
        CGRect rect = [self getWindowSizeWith: windowID];
        NSNumber *width = [NSNumber numberWithDouble:rect.size.width];
        NSNumber *height = [NSNumber numberWithDouble:rect.size.height];
        NSDictionary *data = @{@"width": width, @"height": height};
        result(data);
    } else if([@"checkScreenRecordPermission" isEqualToString:call.method]) {
        BOOL ret = YES;
        do {
            ret = [self checkScreenRecordPermission];
            NSLog(@"---- call checkScreenRecordPermission ret:%@",ret ? @"YES" : @"NO");
            if (!ret) {
                ret = [self checkScreenRecordPermissionV2];
                NSLog(@"---- call checkScreenRecordPermissionV2 ret:%@",ret ? @"YES" : @"NO");
                if (!ret) {
                    ret = [self checkScreenRecordPermissionV3];
                    NSLog(@"---- call checkScreenRecordPermissionV3 ret:%@",ret ? @"YES" : @"NO");
                    break;
                }
                break;
            }
            break;
        } while(0);
        //最终检查到没有权限尝试截图唤起系统弹窗
        if(!ret) {
            [self showScreenRecordingPrompt];
        }
        result(@(ret));
    } else if([@"openScreenCaptureSetting" isEqualToString:call.method]) {
        [self openScreenCaptureSetting];
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
//        NSString *name = [window objectForKey:@"kCGWindowOwnerName" ];
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[window objectForKey:@"kCGWindowBounds"], &bounds);
//        NSLog(@"windowID:%d name:%@   bounds:%@", windowNumber, name, NSStringFromRect(bounds));
        break;
    }
    return bounds;
}

/// 申请屏幕录制权限
- (void)showScreenRecordingPrompt {
  /* macos 10.14 and lower do not require screen recording permission to get window titles */
  if(@available(macos 10.15, *)) {
    /*
     To minimize the intrusion just make a 1px image of the upper left corner
     This way there is no real possibilty to access any private data
     */
    CGImageRef screenshot = CGWindowListCreateImage(
        CGRectMake(0,0,1,1),
        kCGWindowListOptionOnScreenOnly,
        kCGNullWindowID,
        kCGWindowImageDefault);
    CFRelease(screenshot);
  }
}

/// 判断是否获得屏幕录制权限
- (bool) checkScreenRecordPermission {
    if (@available(macos 10.15, *)) {//mac10.15及以上才有屏幕录制授权
        bool bRet = false;
        CFArrayRef list = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
        if (list) {
            int n = (int)(CFArrayGetCount(list));
            for (int i = 0; i < n; i++) {
                NSDictionary* info = (NSDictionary*)(CFArrayGetValueAtIndex(list, (CFIndex)i));
                NSString* name = info[(id)kCGWindowName];
                NSNumber* pid = info[(id)kCGWindowOwnerPID];
                if (pid != nil && name != nil) {
                    int nPid = [pid intValue];
                    char path[PROC_PIDPATHINFO_MAXSIZE+1];
                    int lenPath = proc_pidpath(nPid, path, PROC_PIDPATHINFO_MAXSIZE);
                    if (lenPath > 0) {
                        path[lenPath] = 0;
                        if (strcmp(path, "/System/Library/CoreServices/SystemUIServer.app/Contents/MacOS/SystemUIServer") == 0) {
                            bRet = true;
                            break;
                        }
                    }
                }
            }
            CFRelease(list);
        }
        return bRet;
    } else {
        return true;
    }
}

- (BOOL)checkScreenRecordPermissionV2 {
    if (@available(macOS 10.15, *)) {
        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
        NSUInteger numberOfWindows = CFArrayGetCount(windowList);
        NSUInteger numberOfWindowsWithName = 0;
        for (int idx = 0; idx < numberOfWindows; idx++) {
            NSDictionary *windowInfo = (NSDictionary *)CFArrayGetValueAtIndex(windowList, idx);
            NSString *windowName = windowInfo[(id)kCGWindowName];
            if (windowName) {
                numberOfWindowsWithName++;
            } else {
                //no kCGWindowName detected -> not enabled
                break; //breaking early, numberOfWindowsWithName not increased
            }
        }
        CFRelease(windowList);
        return numberOfWindows == numberOfWindowsWithName;
    }
    return YES;
}

- (BOOL)checkScreenRecordPermissionV3 {
    BOOL canRecordScreen = YES;
    if (@available(macOS 10.15, *)) {
        canRecordScreen = NO;
        NSRunningApplication *runningApplication = NSRunningApplication.currentApplication;
        NSNumber *ourProcessIdentifier = [NSNumber numberWithInteger:runningApplication.processIdentifier];

        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
        NSUInteger numberOfWindows = CFArrayGetCount(windowList);
        for (int index = 0; index < numberOfWindows; index++) {
            // get information for each window
            NSDictionary *windowInfo = (NSDictionary *)CFArrayGetValueAtIndex(windowList, index);
            NSString *windowName = windowInfo[(id)kCGWindowName];
            NSNumber *processIdentifier = windowInfo[(id)kCGWindowOwnerPID];

            // don't check windows owned by this process
            if (! [processIdentifier isEqual:ourProcessIdentifier]) {
                // get process information for each window
                pid_t pid = processIdentifier.intValue;
                NSRunningApplication *windowRunningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
                if (! windowRunningApplication) {
                    // ignore processes we don't have access to, such as WindowServer, which manages the windows named "Menubar" and "Backstop Menubar"
                }
                else {
                    NSString *windowExecutableName = windowRunningApplication.executableURL.lastPathComponent;
                    if (windowName) {
                        if ([windowExecutableName isEqual:@"Dock"]) {
                            // ignore the Dock, which provides the desktop picture
                        }
                        else {
                            canRecordScreen = YES;
                            break;
                        }
                    }
                }
            }
        }
        CFRelease(windowList);
    }
    return canRecordScreen;
}

/// 打开屏幕录制权限设置窗口
- (void) openScreenCaptureSetting {
    NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
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
