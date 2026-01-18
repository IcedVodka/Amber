import 'dart:ui';

class AppConfig {
  static const String appNameZh = '流珀';
  static const String appNameEn = 'Amber';

  static String appName(Locale locale) {
    return locale.languageCode == 'zh' ? appNameZh : appNameEn;
  }
}
