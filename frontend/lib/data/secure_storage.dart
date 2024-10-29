import 'dart:io' show Platform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  FlutterSecureStorage? _storage;

  SecureStorage() {
    if (Platform.isAndroid) {
      _storage = FlutterSecureStorage(
        aOptions: _getAndroidOptions(),
      );
    }
    if (Platform.isIOS) {
      _storage = FlutterSecureStorage(
        iOptions: _getIOSOptions(),
      );
    }
  }

  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  static IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.unlocked,
      );

  Future<void> setItem(String key, String value) async {
    if (_storage != null) {
      await _storage!.write(key: key, value: value);
    }
  }

  Future<String?> getItem(String key) async {
    return _storage != null ? await _storage!.read(key: key) : null;
  }

  Future<void> deleteItem(String key) async {
    if (_storage != null) {
      await _storage!.delete(key: key);
    }
  }

  Future<void> deleteAllItems() async {
    if (_storage != null) {
      await _storage!.deleteAll();
    }
  }
}
