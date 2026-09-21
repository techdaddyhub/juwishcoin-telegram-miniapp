// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:js' as js;

void openUrlImpl(String url) {
  try {
    js.context.callMethod('openExternalLink', [url]);
  } catch (_) {
    // Graceful fallback
  }
}

