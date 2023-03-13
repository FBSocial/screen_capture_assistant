import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screen_capture_assistant_platform_interface.dart';

/// An implementation of [ScreenCaptureAssistantPlatform] that uses method channels.
class MethodChannelScreenCaptureAssistant
    extends ScreenCaptureAssistantPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screen_capture_assistant');

  final _eventChannel = const EventChannel('screen_capture_assistant_event');

  @override
  EventChannel get eventChannel => _eventChannel;

  @override
  Future<void> addObserverReplayKitEvents() async {
    await methodChannel.invokeMethod('addObserverReplayKiteEvents');
  }

  @override
  void listenReplayKitEvents(Function(String?) eventCallback) {
    methodChannel.setMethodCallHandler((call) {
      if (call.arguments is! String) return Future.value();
      eventCallback(call.arguments as String);
      return Future.value();
    });
  }

  @override
  void startObserverScreenCaptureDirection() {
    methodChannel.invokeMethod('startObserverScreenCaptureDirection');
  }

  @override
  void stopObserverScreenCaptureDirection() {
    methodChannel.invokeMethod('stopObserverScreenCaptureDirection');
  }

  @override
  Future<bool?> checkScreenCaptureState() async {
    return await methodChannel.invokeMethod('checkScreenCaptureState');
  }

  @override
  Future<bool?> startCheckWindowSize(int windowID) async {
    return await methodChannel.invokeMethod<bool>(
      'startCheckWindowSize',
      <String, dynamic>{'windowID': windowID},
    );
  }

  @override
  Future<Size> getWindowSize(int windowID) async {
    // NSDictionary *data = @{@"width": width, @"height": height};
    final size = await methodChannel.invokeMethod(
      'getWindowSize',
      <String, dynamic>{'windowID': windowID},
    );
    if (size is! Map) return Size.zero;
    final width = size['width'];
    final height = size['height'];
    return Size(width is int ? width.toDouble() : width,
        height is int ? height.toDouble() : height);
  }

  @override
  void endCheckWindowSize() {
    methodChannel.invokeMethod('endCheckWindowSize');
  }

  @override
  Future<bool?> checkScreenRecordPermission() async {
    return await methodChannel.invokeMethod<bool>('checkScreenRecordPermission');
  }

  @override
  Future<void> openScreenCaptureSetting() async {
    methodChannel.invokeMethod<bool>('openScreenCaptureSetting');
  }

  @override
  Future<bool?> isValidWindow(int windowID) async {
    return await methodChannel
        .invokeMethod<bool>('isValidWindow', <String, dynamic>{
      'windowID': windowID,
    });
  }
}
