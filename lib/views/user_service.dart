import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class UserService {
  static const String _fileName = 'users.json';
  static List<Map<String, dynamic>>? _cachedUsers;

  static Future<List<Map<String, dynamic>>> getUsers() async {
    if (_cachedUsers != null) {
      return _cachedUsers!;
    }

    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$_fileName');

      if (await file.exists()) {
        String contents = await file.readAsString();
        _cachedUsers = List<Map<String, dynamic>>.from(json.decode(contents));
      } else {
        final String response = await rootBundle.loadString('assets/$_fileName');
        _cachedUsers = List<Map<String, dynamic>>.from(json.decode(response));
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
}