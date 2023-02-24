#ifndef FLUTTER_PLUGIN_SCREEN_CAPTURE_ASSISTANT_PLUGIN_H_
#define FLUTTER_PLUGIN_SCREEN_CAPTURE_ASSISTANT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace screen_capture_assistant {

class ScreenCaptureAssistantPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ScreenCaptureAssistantPlugin();

  virtual ~ScreenCaptureAssistantPlugin();

  // Disallow copy and assign.
  ScreenCaptureAssistantPlugin(const ScreenCaptureAssistantPlugin&) = delete;
  ScreenCaptureAssistantPlugin& operator=(const ScreenCaptureAssistantPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace screen_capture_assistant

#endif  // FLUTTER_PLUGIN_SCREEN_CAPTURE_ASSISTANT_PLUGIN_H_
