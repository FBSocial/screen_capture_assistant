import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_capture_assistant/screen_capture_assistant_method_channel.dart';

void main() {
  MethodChannelScreenCaptureAssistant platform =
      MethodChannelScreenCaptureAssistant();
  const MethodChannel channel = MethodChannel('screen_capture_assistant');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });
}
