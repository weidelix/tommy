//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
#include <connectivity_plus/connectivity_plus_windows_plugin.h>
#include <flutter_acrylic/flutter_acrylic_plugin.h>
#include <image_compression_flutter/image_compression_flutter_plugin.h>
#include <system_theme/system_theme_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BitsdojoWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BitsdojoWindowPlugin"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  FlutterAcrylicPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterAcrylicPlugin"));
  ImageCompressionFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ImageCompressionFlutterPlugin"));
  SystemThemePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SystemThemePlugin"));
}
