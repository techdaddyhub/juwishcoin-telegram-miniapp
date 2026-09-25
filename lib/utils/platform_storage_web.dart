// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

void saveStringImpl(String key, String value) {
  try {
    html.window.localStorage[key] = value;
  } catch (_) {}
}

String? getStringImpl(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}

void removeStringImpl(String key) {
  try {
    html.window.localStorage.remove(key);
  } catch (_) {}
}
