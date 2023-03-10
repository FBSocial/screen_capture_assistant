import 'package:flutter/services.dart';

import 'screen_capture_assistant_platform_interface.dart';

/// iOS屏幕共享时的辅助插件
///
/// iOS屏幕共享是在子进程中，需要通过进程通知来通信
/// 1. ReplayKit录制的开始与停止事件
/// 2. 录制时的屏幕方向变化事件
/// 3. 检测iOS是否正在屏幕共享
///
/// TODO: 之前直播外包代码的逻辑混乱各种事件eventBus乱飞，且多个插件比较乱, 此插件做了些优化，但还有优化的空间
/// 1. methodChannel只用于启动事件监听，而真正的事件监听应该使用eventChannel去做
/// 2. 考虑将所有事件具体类化，并统一处理
/// 3. 进程通知里传屏幕方向没必要写硬盘，应该直接传userinfo可以
class ScreenCaptureAssistant {
  static EventChannel get eventChannel =>
      ScreenCaptureAssistantPlatform.instance.eventChannel;

  /// 开启监听iOS ReplayKit的开始与停止事件
  static Future<void> addObserverReplayKitEvents() async {
    ScreenCaptureAssistantPlatform.instance.addObserverReplayKitEvents();
  }

  /// 监听iOSReplayKit的开始与停止事件
  ///
  /// 这个不需要自己去移除监听， 因为[addObserverReplayKiteEvents]中原生处监听到一次之后会自动removeObserver
  static void listenReplayKitEvents(Function(String?) eventCallback) {
    ScreenCaptureAssistantPlatform.instance
        .listenReplayKitEvents(eventCallback);
  }

  /// 开启监听屏幕共享时的屏幕方向变化
  static void startObserverScreenCaptureDirection() {
    ScreenCaptureAssistantPlatform.instance
        .startObserverScreenCaptureDirection();
  }

  /// 关闭监听屏幕共享时的屏幕方向变化
  static void stopObserverScreenCaptureDirection() {
    ScreenCaptureAssistantPlatform.instance
        .stopObserverScreenCaptureDirection();
  }

  /// 开始检查屏幕共享窗口宽高变化
  static Future<bool?> startCheckWindowSize(int windowID) async {
    return ScreenCaptureAssistantPlatform.instance
        .startCheckWindowSize(windowID);
  }

  /// 结束屏幕共享窗口宽高变化
  static void endCheckWindowSize() {
    ScreenCaptureAssistantPlatform.instance.endCheckWindowSize();
  }

  /// 监听屏幕共享时的屏幕方向变化与屏幕共享是否开启的状态
  ///
  /// 此方法在应用启动调用， 此后只有使用[startObserverScreenCaptureDirection]、 [checkScreenCaptureState]等才会有事件回调
  /// 对应的，若调用了[stopObserverScreenCaptureDirection]将不会有方向改变回调
  static void listenEvents(
      Function(ScreenCaptureAssistantEvent, dynamic data) callback) {
    eventChannel.receiveBroadcastStream().listen((eventMap) {
      if (eventMap is! Map) return;
      final eventName = eventMap['event'];
      final data = eventMap['data'];
      if (eventName == 'direction') {
        callback(ScreenCaptureAssistantEvent.directionChange, data);
      } else if (eventName == 'screenCaptureState') {
        callback(ScreenCaptureAssistantEvent.screenCaptureState, data);
      } else if (eventName == 'onShareWindowResizeEvent') {
        callback(ScreenCaptureAssistantEvent.shareWindowResizeEvent, data);
      }
    });
  }

  /// 检查iOS 屏幕共享状态，是否正在screen capture
  static Future<bool?> checkScreenCaptureState() async {
    return ScreenCaptureAssistantPlatform.instance.checkScreenCaptureState();
  }
}

enum ScreenCaptureAssistantEvent {
  directionChange,
  screenCaptureState,
  shareWindowResizeEvent,
}
