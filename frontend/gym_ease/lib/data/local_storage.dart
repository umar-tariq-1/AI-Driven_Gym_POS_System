import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<void> setItem(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else if (value is Map<String, dynamic>) {
      await prefs.setString(key, jsonEncode(value));
    } else {
      throw Exception("Unsupported value type");
    }
  }

  Future<void> setItems(List<String> keys, List<dynamic> values) async {
    if (keys.length != values.length) {
      throw Exception("Keys and values arrays must have the same length");
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final value = values[i];

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      } else if (value is Map<String, dynamic>) {
        await prefs.setString(key, jsonEncode(value));
      } else {
        throw Exception("Unsupported value type at index $i");
      }
    }
  }

  Future<dynamic> getItem(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key)) {
      Object? value = prefs.get(key);

      if (value is String) {
        try {
          return jsonDecode(value);
        } catch (e) {
          return value;
        }
      } else {
        return value;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getItems(List<String> keys) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> result = {};

    for (String key in keys) {
      final value = prefs.get(key);

      if (value is String) {
        try {
          result[key] = jsonDecode(value);
        } catch (e) {
          result[key] = value;
        }
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  Future<void> deleteItem(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> deleteItems(List<String> keys) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String key in keys) {
      await prefs.remove(key);
    }
  }

  Future<void> deleteAllItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
