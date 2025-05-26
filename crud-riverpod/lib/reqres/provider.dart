import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api.dart';
import 'models.dart';

final userListProvider = AsyncNotifierProvider<UserListNotifier, List<User>>(() {
  return UserListNotifier();
});

class UserListNotifier extends AsyncNotifier<List<User>> {
  UserAPI get _userAPI => ref.read(userAPIProvider.notifier);

  @override
  Future<List<User>> build() async {
    return await _userAPI.fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _userAPI.fetchUsers();
    });
  }

  Future<void> addUser(User user) async {
    state = await AsyncValue.guard(() async {
      final currentUsers = state.value ?? [];
      return [...currentUsers, user];
    });
  }

  Future<void> updateUserInList(User user) async {
    state = await AsyncValue.guard(() async {
      final currentUsers = state.value ?? [];
      final index = currentUsers.indexWhere((u) => u.id == user.id);
      if (index == -1) return currentUsers;
      final updated = List<User>.from(currentUsers);
      updated[index] = user;
      return updated;
    });
  }

  Future<void> removeUser(int id) async {
    state = await AsyncValue.guard(() async {
      final currentUsers = state.value ?? [];
      return currentUsers.where((u) => u.id != id).toList();
    });
  }
}