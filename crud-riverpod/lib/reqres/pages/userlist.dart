import 'package:crud_riverpod/reqres/pages/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../provider.dart';

class UserListPage extends ConsumerWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userListProvider.notifier).fetchUsers();
        },
        child: usersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (users) {
            if (users.isEmpty) {
              return const Center(child: Text('No users found.'));
            }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return UserListTile(user: user);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showUserForm(context,ref),
      child: const Icon(Icons.add),
    ),
    );
  }

  Future<void> _showUserForm(BuildContext context, WidgetRef ref, {User ? user}) async {
    final firstNameController = TextEditingController(text: user?.firstName ?? '');
    final lastNameController = TextEditingController(text: user?.lastName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(userRepositoryProvider);
              final userListNotifier = ref.read(userListProvider.notifier);

              final firstName = firstNameController.text.trim();
              final lastName = lastNameController.text.trim();
              final email = emailController.text.trim();

              if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')));
                return;
              }

              Navigator.pop(context);
              try {
                if (user == null) {
                  final newUser  = await repo.createUser (firstName, lastName);
                  await userListNotifier.addUser (newUser );
                } else {
                  final updatedUser  = await repo.updateUser (user.id!, 'morpheus', 'zion resident');
                  await userListNotifier.updateUserInList(updatedUser );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(user == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}