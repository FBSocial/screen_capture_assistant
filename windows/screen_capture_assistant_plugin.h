#ifndef FLUTTER_PLUGIN_SCREEN_CAPTURE_ASSISTANT_PLUGIN_H_
#define FLUTTER_PLUGIN_SCREEN_CAPTURE_ASSISTANT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/event_channel.h>
#include <memory>

namespace screen_capture_assistant {

  struct WndSize {
    LONG wndWidth;
    LONG wndHeight;
    WndSize(LONG w = 0, LONG h = 0) : wndWidth(w), wndHeight(h) {}
  };

class ScreenCaptureAssistantPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ScreenCaptureAssistantPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~ScreenCaptureAssistantPlugin();

  // Disallow copy and assign.
  ScreenCaptureAssistantPlugin(const ScreenCaptureAssistantPlugin&) = delete;
  ScreenCaptureAssistantPlugin& operator=(const ScreenCaptureAssistantPlugin&) = delete;

  std::optional<LRESULT> HandleWindowProc(HWND hwnd,
    UINT message,
    WPARAM wparam,
    LPARAM lparam);

protected:
  void onShareWindowResizeEvent(const int width, const int height);
  void checkShareWindowResize();
  WndSize getWndSize() const;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>> _eventChannel;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> _eventSink;

  // The registrar for this plugin.
  flutter::PluginRegistrarWindows* registrar_ = nullptr;

  // The ID of the registered WindowProc handler.
  int window_proc_id_;

  //share window width and height
  WndSize _wndSize;

  HWND _hwnd; //myApp handle
  HWND _myHwnd; //share window handle
};

}  // namespace screen_capture_assistant

#endif  // FLUTTER_PLUGIN_SCREEN_CAPTURE_ASSISTANT_PLUGIN_H_
