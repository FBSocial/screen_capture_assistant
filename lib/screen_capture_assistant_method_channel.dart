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
  void startCheckWindowSize() {
    methodChannel.invokeMethod('startCheckWindowSize');
  }

  @override
  void endCheckWindowSize() {
    methodChannel.invokeMethod('endCheckWindowSize');
  }
}
