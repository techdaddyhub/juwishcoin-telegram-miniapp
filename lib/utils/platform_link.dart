import 'platform_link_stub.dart'
    if (dart.library.js) 'platform_link_web.dart';

void openExternalUrl(String url) {
  openUrlImpl(url);
}

