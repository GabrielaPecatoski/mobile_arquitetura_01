import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SessionManager {
  static const _userKey = 'authenticated_user';

  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static bool get isLoggedIn => _currentUser != null;

  static Future<void> saveUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    final user = User.fromMap(
      jsonDecode(userJson) as Map<String, dynamic>,
    );
    _currentUser = user;
    return user;
  }

  static Future<void> clearUser() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
