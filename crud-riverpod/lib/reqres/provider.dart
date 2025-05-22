import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api.dart';
import 'models.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());

final userListProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<User>>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserListNotifier(repository);
});

class UserListNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserRepository repository;
  UserListNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final users = await repository.fetchUsers();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchUsers() async {
    await loadUsers();
  }

  Future<void> addUser(User user) async {
    final currentUsers = state.value ?? [];
    state = AsyncValue.data([...currentUsers, user]);
  }

  Future<void> updateUserInList(User user) async {
    final currentUsers = state.value ?? [];
    final index = currentUsers.indexWhere((u) => u.id == user.id);
    if (index == -1) return;
    currentUsers[index] = user;
    state = AsyncValue.data(List.from(currentUsers));
  }

  Future<void> removeUser(int id) async {
    final currentUsers = state.value ?? [];
    final updated = currentUsers.where((u) => u.id != id).toList();
    state = AsyncValue.data(updated);
  }
}