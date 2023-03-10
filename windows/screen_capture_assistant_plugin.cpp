#include "screen_capture_assistant_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/encodable_value.h>

#include <memory>
#include <sstream>
#include <map>

#include <iostream>

const UINT ID_CHECK_TIMER = 101;

namespace screen_capture_assistant {

// static
void ScreenCaptureAssistantPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "screen_capture_assistant",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<ScreenCaptureAssistantPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

ScreenCaptureAssistantPlugin::ScreenCaptureAssistantPlugin(
  flutter::PluginRegistrarWindows* registrar) : 
  registrar_(registrar),
  _hwnd(NULL),
  _myHwnd(NULL)
{
  _eventChannel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(registrar->messenger(), 
    "screen_capture_assistant_event", &flutter::StandardMethodCodec::GetInstance());
  auto handler = std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>([this](const flutter::EncodableValue* arguments, std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
    _eventSink = std::move(events);
    return nullptr;
    }, [](const flutter::EncodableValue* arguments) {
      return nullptr;
    });
  _eventChannel->SetStreamHandler(std::move(handler));

  window_proc_id_ = registrar_->RegisterTopLevelWindowProcDelegate(
    [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
      return HandleWindowProc(hwnd, message, wparam, lparam);
    });
}

ScreenCaptureAssistantPlugin::~ScreenCaptureAssistantPlugin() {
  if (_hwnd) {
    KillTimer(_myHwnd, ID_CHECK_TIMER);
  }
  registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_id_);
}

std::optional<LRESULT> ScreenCaptureAssistantPlugin::HandleWindowProc(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam)
{
  if (!_myHwnd) {
    _myHwnd = hwnd;
  }
  if (message == WM_TIMER) {
    if (wparam == ID_CHECK_TIMER) {
      std::cout << "==== checking ====" << std::endl;
      if (_hwnd) {
        //check now share window resize
        checkShareWindowResize();
      }
    }
  }
  return std::optional<LRESULT>();
}

void ScreenCaptureAssistantPlugin::onShareWindowResizeEvent(const int width, const int height)
{
  std::cout << "==== window resize ====" << std::endl;
  const auto event = flutter::EncodableValue(flutter::EncodableMap {
    { flutter::EncodableValue("event"), flutter::EncodableValue("onShareWindowResizeEvent") },
    { flutter::EncodableValue("width"), flutter::EncodableValue(width) },
    { flutter::EncodableValue("height"), flutter::EncodableValue(height) },
  });
  _eventSink->Success(event);
}

void ScreenCaptureAssistantPlugin::checkShareWindowResize()
{
  auto wndsize = getWndSize();
  if (wndsize.wndWidth != _wndSize.wndWidth || wndsize.wndHeight != _wndSize.wndHeight) {
    onShareWindowResizeEvent(wndsize.wndWidth, wndsize.wndHeight);
    _wndSize.wndWidth = wndsize.wndWidth;
    _wndSize.wndHeight = wndsize.wndHeight;
  }
  std::cout << " width: " << _wndSize.wndWidth << " height: " << _wndSize.wndHeight << std::endl;
}

WndSize ScreenCaptureAssistantPlugin::getWndSize() const
{
  RECT window_rect;
  WndSize wndSize;
  if (_hwnd && ::GetWindowRect(_hwnd, &window_rect)) {
    wndSize.wndWidth = window_rect.right - window_rect.left;
    wndSize.wndHeight = window_rect.bottom - window_rect.top;
  }
  return wndSize;
}

void ScreenCaptureAssistantPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    //std::ostringstream version_stream;
    //version_stream << "Windows ";
    //if (IsWindows10OrGreater()) {
    //  version_stream << "10+";
    //} else if (IsWindows8OrGreater()) {
    //  version_stream << "8";
    //} else if (IsWindows7OrGreater()) {
    //  version_stream << "7";
    //}
    //result->Success(flutter::EncodableValue(version_stream.str()));
  }else if(method_call.method_name().compare("startCheckWindowSize") == 0) {
    //std::cout << "---------startCheckWindowSize" << std::endl;
    flutter::EncodableMap arguments =
      std::get<flutter::EncodableMap>(*method_call.arguments());
    int32_t windowId = std::get<int>(arguments[flutter::EncodableValue("windowId")]);
    _hwnd = (HWND)windowId;
    _wndSize = getWndSize();
    SetTimer(_myHwnd, ID_CHECK_TIMER, 500, NULL);
    result->Success(true);
  } else if(method_call.method_name().compare("stopCheckWindowSize") == 0) {
    //std::cout << "---------stopCheckWindowSize" << std::endl;
    KillTimer(_myHwnd, ID_CHECK_TIMER);
    _hwnd = NULL;
    result->Success(true);
  }else {
    result->NotImplemented();
  }
}

}  // namespace screen_capture_assistant
