import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';
import '../services/auth_service.dart';
import '../services/shared_preference.dart';

final httpClientProvider = Provider((ref) => http.Client());
final sharedPrefsProvider = Provider((ref) => SharedPrefsService());

final authServiceProvider = Provider((ref) {
  final client = ref.read(httpClientProvider);
  return AuthService(client: client);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthUser?>((ref) {
  final authService = ref.read(authServiceProvider);
  final sharedPrefs = ref.read(sharedPrefsProvider);
  return AuthNotifier(authService, sharedPrefs);
});

class AuthNotifier extends StateNotifier<AuthUser?> {
  final AuthService _authService;
  final SharedPrefsService _sharedPrefs;

  AuthNotifier(this._authService, this._sharedPrefs) : super(null) {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    final user = await _sharedPrefs.getAuthUser();
    if (user != null) {
      state = user;
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final user = await _authService.login(username, password);
      await _sharedPrefs.saveAuthUser(user);
      state = user;
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  Future<void> register(String email, String username, String password) async {
    try {
      final user = await _authService.register(email, username, password);
      state = user;
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  Future<void> logout() async {
    if (state != null) {
      await _authService.logout(state!.token);
      await _sharedPrefs.clearAuthUser();
      state = null;
    }
  }
}