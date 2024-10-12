import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _fileName = 'users.json';
  static const String _appEnabledKey = 'app_enabled';
  static const String _lastPasswordChangeKey = 'last_password_change';
  static List<Map<String, dynamic>>? _cachedUsers;

  static Future<List<Map<String, dynamic>>> getUsers() async {
    if (_cachedUsers != null) return _cachedUsers!;

    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$_fileName');

      if (await file.exists()) {
        String contents = await file.readAsString();
        List<dynamic> jsonList = json.decode(contents);
        _cachedUsers = List<Map<String, dynamic>>.from(jsonList);
      } else {
        final String response = await rootBundle.loadString('assets/users.json');
        List<dynamic> jsonList = json.decode(response);
        _cachedUsers = List<Map<String, dynamic>>.from(jsonList);
        await _saveUsers(_cachedUsers!);
      }
      return _cachedUsers!;
    } catch (e) {
      print("Error loading users: $e");
      return [];
    }
  }

  static Future<void> addUser(Map<String, dynamic> newUser) async {
    List<Map<String, dynamic>> users = await getUsers();
    users.add(newUser);
    await _saveUsers(users);
  }

  static Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    try {
      final String jsonString = json.encode(users);
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$_fileName');
      await file.writeAsString(jsonString);
      _cachedUsers = users;
      print("Users saved successfully");
    } catch (e) {
      print("Error saving users: $e");
    }
  }

  static Future<void> updateUsers(List<Map<String, dynamic>> users) async {
    await _saveUsers(users);
  }

  static Future<bool> isAppEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appEnabledKey) ?? true;
  }

  static Future<void> setAppEnabled(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appEnabledKey, enabled);
  }

  static Future<DateTime?> getLastPasswordChangeDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? timestamp = prefs.getInt(_lastPasswordChangeKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  static Future<void> updateLastPasswordChangeDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPasswordChangeKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> shouldRemindPasswordChange() async {
    DateTime? lastChange = await getLastPasswordChangeDate();
    if (lastChange == null) return true;
    return DateTime.now().difference(lastChange).inMinutes >= 2;
  }

  static Future<void> changeAdminPassword(String newPassword) async {
    List<Map<String, dynamic>> users = await getUsers();
    int adminIndex = users.indexWhere((user) => user['alias'] == 'Admin');
    if (adminIndex != -1) {
      users[adminIndex]['contrasena'] = newPassword;
      await _saveUsers(users);
      await updateLastPasswordChangeDate();
    }
  }
}