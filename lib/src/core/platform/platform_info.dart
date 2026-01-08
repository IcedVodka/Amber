import 'dart:io';

class PlatformInfo {
  const PlatformInfo._();

  static bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;
}
