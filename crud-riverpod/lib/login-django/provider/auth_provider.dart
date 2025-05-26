import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';
import '../services/auth_service.dart';
import '../services/shared_preference.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
http.Client httpClient(HttpClientRef ref) => http.Client();

@Riverpod(keepAlive: true)
SharedPrefsService sharedPrefs(SharedPrefsRef ref) => SharedPrefsService();

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  final client = ref.watch(httpClientProvider);
  return AuthService(client: client);
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthUser?> build() async {
    final sharedPrefs = ref.watch(sharedPrefsProvider);
    return await sharedPrefs.getAuthUser();
  }

  Future<void> login(String username, String password) async {
    final authService = ref.watch(authServiceProvider);
    final sharedPrefs = ref.watch(sharedPrefsProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await authService.login(username, password);
      await sharedPrefs.saveAuthUser(user);
      return user;
    });
  }

  Future<void> register(String email, String username, String password) async {
    final authService = ref.watch(authServiceProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await authService.register(email, username, password);
    });
  }

  Future<void> logout() async {
    final authService = ref.watch(authServiceProvider);
    final sharedPrefs = ref.watch(sharedPrefsProvider);
    final currentUser = state.value;

    if (currentUser != null) {
      await authService.logout(currentUser.token);
      await sharedPrefs.clearAuthUser();
      state = const AsyncValue.data(null);
    }
  }
}