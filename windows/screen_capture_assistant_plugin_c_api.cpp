#include "include/screen_capture_assistant/screen_capture_assistant_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "screen_capture_assistant_plugin.h"

void ScreenCaptureAssistantPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  screen_capture_assistant::ScreenCaptureAssistantPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
