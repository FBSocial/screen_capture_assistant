import 'package:flutter/src/services/platform_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_capture_assistant/screen_capture_assistant_platform_interface.dart';
import 'package:screen_capture_assistant/screen_capture_assistant_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScreenCaptureAssistantPlatform
    with MockPlatformInterfaceMixin
    implements ScreenCaptureAssistantPlatform {
  @override
  void listenReplayKitEvents(Function(String? p1) eventCallback) {
    // TODO: implement listenReplayKitEvents
  }

  @override
  Future<bool?> checkScreenCaptureState() {
    // TODO: implement checkScreenCaptureState
    throw UnimplementedError();
  }

  @override
  // TODO: implement eventChannel
  EventChannel get eventChannel => throw UnimplementedError();

  @override
  Future<void> addObserverReplayKitEvents() {
    // TODO: implement addObserverReplayKitEvents
    throw UnimplementedError();
  }

  @override
  void startObserverScreenCaptureDirection() {
    // TODO: implement startObserverScreenCaptureDirection
  }

  @override
  void stopObserverScreenCaptureDirection() {
    // TODO: implement stopObserverScreenCaptureDirection
  }
}

void main() {
  final ScreenCaptureAssistantPlatform initialPlatform =
      ScreenCaptureAssistantPlatform.instance;

  test('$MethodChannelScreenCaptureAssistant is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelScreenCaptureAssistant>());
  });
  //
  // test('getPlatformVersion', () async {
  //   ScreenCaptureAssistant screenCaptureAssistantPlugin = ScreenCaptureAssistant();
  //   MockScreenCaptureAssistantPlatform fakePlatform = MockScreenCaptureAssistantPlatform();
  //   ScreenCaptureAssistantPlatform.instance = fakePlatform;
  //
  //   expect(await screenCaptureAssistantPlugin.getPlatformVersion(), '42');
  // });
}
