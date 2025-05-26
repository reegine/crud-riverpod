import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';
import 'dart:convert';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> saveAuthUser(AuthUser user) async {
    final prefs = await _instance;
    await prefs.setString('auth_user', json.encode(user.toJson()));
  }

  Future<AuthUser?> getAuthUser() async {
    final prefs = await _instance;
    final userJson = prefs.getString('auth_user');
    if (userJson != null) {
      return AuthUser.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<void> clearAuthUser() async {
    final prefs = await _instance;
    await prefs.remove('auth_user');
  }
}