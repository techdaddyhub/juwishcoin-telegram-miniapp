// In-memory fallback for non-web environments (tests, VM)
final Map<String, String> _memoryStorage = {};

void saveStringImpl(String key, String value) {
  _memoryStorage[key] = value;
}

String? getStringImpl(String key) {
  return _memoryStorage[key];
}

void removeStringImpl(String key) {
  _memoryStorage.remove(key);
}
