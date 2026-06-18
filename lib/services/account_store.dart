import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AccountStore {
  static const _key = 'registered_accounts';

  static Future<List<Map<String, dynamic>>> _all() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  static Future<bool> usernameExists(String username) async {
    final accounts = await _all();
    final target = username.toLowerCase();
    return accounts
        .any((a) => (a['username'] as String).toLowerCase() == target);
  }

  static Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await _all();

    final target = username.toLowerCase();
    if (accounts.any((a) => (a['username'] as String).toLowerCase() == target)) {
      throw Exception('Este nome de usuário já está em uso.');
    }

    final account = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'password': password,
    };
    accounts.add(account);
    await prefs.setString(_key, jsonEncode(accounts));

    return _toUser(account);
  }

  static Future<User?> authenticate(String username, String password) async {
    final accounts = await _all();
    final target = username.toLowerCase();
    for (final a in accounts) {
      if ((a['username'] as String).toLowerCase() == target &&
          a['password'] == password) {
        return _toUser(a);
      }
    }
    return null;
  }

  static User _toUser(Map<String, dynamic> a) {
    return User(
      id: a['id'] as int,
      username: a['username'] as String,
      email: a['email'] as String,
      firstName: a['firstName'] as String,
      lastName: a['lastName'] as String,
      image: '',
      token: '',
      refreshToken: '',
    );
  }
}
