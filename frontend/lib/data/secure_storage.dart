import 'dart:convert';
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

  Future<void> setItem(String key, dynamic value) async {
    if (_storage != null) {
      String dataToStore;
      if (value is Map) {
        dataToStore = jsonEncode(value);
      } else {
        dataToStore = value.toString();
      }
      await _storage!.write(key: key, value: dataToStore);
    }
  }

  Future<dynamic> getItem(String key) async {
    if (_storage != null) {
      final data = await _storage!.read(key: key);
      if (data != null) {
        try {
          final decodedData = jsonDecode(data);
          if (decodedData is Map) {
            return decodedData;
          }
        } catch (_) {
          // Not JSON, return as is
        }
      }
      return data;
    }
    return null;
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

  Future<void> setItems(List<String> keys, List<dynamic> values) async {
    if (_storage != null && keys.length == values.length) {
      for (int i = 0; i < keys.length; i++) {
        await setItem(keys[i], values[i]);
      }
    }
  }

  Future<Map<String, dynamic>> getItems(List<String> keys) async {
    Map<String, dynamic> results = {};
    if (_storage != null) {
      for (String key in keys) {
        results[key] = await getItem(key);
      }
    }
    return results;
  }

  Future<void> deleteItems(List<String> keys) async {
    if (_storage != null) {
      for (String key in keys) {
        await deleteItem(key);
      }
    }
  }
}
