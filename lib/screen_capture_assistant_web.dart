// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/src/services/platform_channel.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'screen_capture_assistant_platform_interface.dart';

/// A web implementation of the ScreenCaptureAssistantPlatform of the ScreenCaptureAssistant plugin.
class ScreenCaptureAssistantWeb extends ScreenCaptureAssistantPlatform {
  /// Constructs a ScreenCaptureAssistantWeb
  ScreenCaptureAssistantWeb();

  static void registerWith(Registrar registrar) {
    ScreenCaptureAssistantPlatform.instance = ScreenCaptureAssistantWeb();
  }

  @override
  EventChannel get eventChannel => throw UnimplementedError();
}
