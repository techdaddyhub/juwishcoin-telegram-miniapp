import 'platform_storage_stub.dart'
    if (dart.library.html) 'platform_storage_web.dart';

class PlatformStorage {
  static void saveString(String key, String value) {
    saveStringImpl(key, value);
  }

  static String? getString(String key) {
    return getStringImpl(key);
  }

  static void removeString(String key) {
    removeStringImpl(key);
  }

  static void saveDouble(String key, double value) {
    saveStringImpl(key, value.toString());
  }

  static double? getDouble(String key) {
    final str = getStringImpl(key);
    if (str == null) return null;
    return double.tryParse(str);
  }

  static void saveInt(String key, int value) {
    saveStringImpl(key, value.toString());
  }

  static int? getInt(String key) {
    final str = getStringImpl(key);
    if (str == null) return null;
    return int.tryParse(str);
  }

  static void saveBool(String key, bool value) {
    saveStringImpl(key, value ? '1' : '0');
  }

  static bool? getBool(String key) {
    final str = getStringImpl(key);
    if (str == null) return null;
    return str == '1';
  }
}
