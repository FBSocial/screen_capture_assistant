import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'screen_capture_assistant_method_channel.dart';

abstract class ScreenCaptureAssistantPlatform extends PlatformInterface {
  /// Constructs a ScreenCaptureAssistantPlatform.
  ScreenCaptureAssistantPlatform() : super(token: _token);

  static final Object _token = Object();

  static ScreenCaptureAssistantPlatform _instance =
      MethodChannelScreenCaptureAssistant();

  /// The default instance of [ScreenCaptureAssistantPlatform] to use.
  ///
  /// Defaults to [MethodChannelScreenCaptureAssistant].
  static ScreenCaptureAssistantPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScreenCaptureAssistantPlatform] when
  /// they register themselves.
  static set instance(ScreenCaptureAssistantPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  EventChannel get eventChannel;

  Future<void> addObserverReplayKitEvents() {
    throw UnimplementedError(
        'addObserverReplayKiteEvents() has not been implemented.');
  }

  void listenReplayKitEvents(Function(String?) eventCallback) {
    throw UnimplementedError(
        'listenReplayKitEvents() has not been implemented.');
  }

  void startObserverScreenCaptureDirection() {
    throw UnimplementedError(
        'startScreenCaptureDirection() has not been implemented.');
  }

  void stopObserverScreenCaptureDirection() {
    throw UnimplementedError(
        'stopObserverScreenCaptureDirection() has not been implemented.');
  }

  Future<bool?> checkScreenCaptureState() async {
    throw UnimplementedError(
        'checkScreenCaptureState() has not been implemented.');
  }

  Future<bool?> startCheckWindowSize(int windowID) async {
    throw UnimplementedError(
        'startCheckWindowSize() has not been implemented.');
  }

  void endCheckWindowSize() {
    throw UnimplementedError('endCheckWindowSize() has not been implemented.');
  }

  Future<Size> getWindowSize(int windowID) async {
    throw UnimplementedError('getWindowSize() has not been implemented.');
  }

  Future<bool?> checkScreenRecordPermission() async {
    throw UnimplementedError('checkScreenRecordPermission() has not been implemented.');
  }

  Future<void> openScreenCaptureSetting() async {
    throw UnimplementedError('openScreenCaptureSetting() has not been implemented.');
  }

  Future<bool?> isValidWindow(int windowID) async {
    throw UnimplementedError('isValidWindow() has not been implemented.');
  }
}
